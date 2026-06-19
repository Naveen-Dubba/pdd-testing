from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
from dotenv import load_dotenv
import os
import pymysql

# Load environment variables from .env file
load_dotenv()

pymysql.install_as_MySQLdb()

app = Flask(__name__)
CORS(app)

# ✅ Reads from Railway environment variable with SQLite fallback
db_url = os.environ.get('DATABASE_URL')
if not db_url:
    db_url = 'sqlite:///aivastra.db'
elif db_url.startswith('postgres://'):
    db_url = db_url.replace('postgres://', 'postgresql://', 1)

app.config['SQLALCHEMY_DATABASE_URI'] = db_url
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'fallback_dev_key_change_in_production')

db = SQLAlchemy(app)


# ─────────────────────────────────────────
# MODELS
# ─────────────────────────────────────────

class User(db.Model):
    __tablename__ = 'users'
    id         = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name       = db.Column(db.String(255), nullable=False)
    email      = db.Column(db.String(255), unique=True, nullable=False)
    password   = db.Column(db.String(255), nullable=False)
    gender     = db.Column(db.String(20),  nullable=True)
    age        = db.Column(db.Integer,     nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)


class ActiveSession(db.Model):
    __tablename__ = 'active_sessions'
    id       = db.Column(db.Integer, primary_key=True, autoincrement=True)
    email    = db.Column(db.String(255), nullable=False)
    login_at = db.Column(db.DateTime, default=datetime.utcnow)


class Analysis(db.Model):
    __tablename__ = 'analyses'
    id                = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id           = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    gender            = db.Column(db.String(20),  nullable=False)
    face_shape        = db.Column(db.String(50),  nullable=True)
    skin_tone         = db.Column(db.String(50),  nullable=True)
    body_type         = db.Column(db.String(100), nullable=True)
    size_suggestion   = db.Column(db.String(50),  nullable=True)
    style_personality = db.Column(db.String(100), nullable=True)
    best_color        = db.Column(db.String(50),  nullable=True)
    created_at        = db.Column(db.DateTime, default=datetime.utcnow)


# ─────────────────────────────────────────
# AUTH
# ─────────────────────────────────────────

@app.route('/register', methods=['POST'])
def register():
    try:
        data     = request.get_json()
        required = ['name', 'email', 'password']
        if not data or not all(k in data for k in required):
            return jsonify({'error': 'Missing required fields'}), 400
        if User.query.filter_by(email=data['email']).first():
            return jsonify({'error': 'Email already registered'}), 409
        new_user = User(
            name=data['name'], email=data['email'],
            password=generate_password_hash(data['password']),
            gender=data.get('gender'), age=data.get('age')
        )
        db.session.add(new_user)
        db.session.commit()
        return jsonify({'message': 'User registered successfully', 'user': {
            'id': new_user.id, 'name': new_user.name, 'email': new_user.email,
            'gender': new_user.gender, 'age': new_user.age
        }}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Server error: {str(e)}'}), 500


@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        if not data or 'email' not in data or 'password' not in data:
            return jsonify({'error': 'Email and password required'}), 400
        user = User.query.filter_by(email=data['email']).first()
        if not user or not check_password_hash(user.password, data['password']):
            return jsonify({'error': 'Invalid credentials'}), 401
        session = ActiveSession(email=user.email)
        db.session.add(session)
        db.session.commit()
        return jsonify({'message': 'Login successful', 'user': {
            'id': user.id, 'name': user.name, 'email': user.email,
            'gender': user.gender, 'age': user.age
        }}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Server error: {str(e)}'}), 500


@app.route('/get_current_user', methods=['GET'])
def get_current_user():
    try:
        last = ActiveSession.query.order_by(ActiveSession.id.desc()).first()
        if not last:
            return jsonify({'error': 'No active user found'}), 404
        user = User.query.filter_by(email=last.email).first()
        if not user:
            return jsonify({'error': 'User not found'}), 404
        return jsonify({
            'id': user.id, 'name': user.name, 'email': user.email,
            'gender': user.gender, 'age': user.age
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/logout', methods=['POST'])
def logout():
    try:
        ActiveSession.query.delete()
        db.session.commit()
        return jsonify({'message': 'Logged out'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


# ─────────────────────────────────────────
# USER PROFILE UPDATE
# ─────────────────────────────────────────

@app.route('/user/update', methods=['PUT'])
def update_user():
    try:
        data = request.get_json()
        if not data or 'email' not in data:
            return jsonify({'error': 'Email is required'}), 400
        user = User.query.filter_by(email=data['email']).first()
        if not user:
            return jsonify({'error': 'User not found'}), 404
        if 'name' in data:
            user.name = data['name']
        if 'gender' in data:
            user.gender = data['gender']
        if 'age' in data:
            user.age = data['age']
        db.session.commit()
        return jsonify({'message': 'Profile updated', 'user': {
            'id': user.id, 'name': user.name, 'email': user.email,
            'gender': user.gender, 'age': user.age
        }}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Server error: {str(e)}'}), 500


# ─────────────────────────────────────────
# ANALYSES
# ─────────────────────────────────────────

@app.route('/analysis', methods=['POST'])
def add_analysis():
    try:
        data     = request.get_json()
        required = ['user_id', 'gender']
        if not data or not all(k in data for k in required):
            return jsonify({'error': 'Missing required fields'}), 400
        analysis = Analysis(
            user_id=data['user_id'], gender=data['gender'],
            face_shape=data.get('face_shape'), skin_tone=data.get('skin_tone'),
            body_type=data.get('body_type'), size_suggestion=data.get('size_suggestion'),
            style_personality=data.get('style_personality'), best_color=data.get('best_color')
        )
        db.session.add(analysis)
        db.session.commit()
        return jsonify({'message': 'Analysis saved', 'id': analysis.id}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


@app.route('/analysis/<int:user_id>', methods=['GET'])
def get_analyses(user_id):
    try:
        items = Analysis.query.filter_by(user_id=user_id)\
            .order_by(Analysis.created_at.desc()).all()
        return jsonify([{
            'id': a.id, 'gender': a.gender, 'face_shape': a.face_shape,
            'skin_tone': a.skin_tone, 'body_type': a.body_type,
            'size_suggestion': a.size_suggestion,
            'style_personality': a.style_personality, 'best_color': a.best_color,
            'created_at': a.created_at.strftime('%d %b %Y, %I:%M %p') if a.created_at else None
        } for a in items]), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/analysis/<int:analysis_id>', methods=['DELETE'])
def delete_analysis(analysis_id):
    try:
        a = Analysis.query.get(analysis_id)
        if not a:
            return jsonify({'error': 'Analysis not found'}), 404
        db.session.delete(a)
        db.session.commit()
        return jsonify({'message': 'Analysis deleted'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


@app.route('/analysis/clear/<int:user_id>', methods=['DELETE'])
def clear_analyses(user_id):
    try:
        Analysis.query.filter_by(user_id=user_id).delete()
        db.session.commit()
        return jsonify({'message': 'History cleared'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


# ─────────────────────────────────────────
# DASHBOARD
# ─────────────────────────────────────────

@app.route('/dashboard/<int:user_id>', methods=['GET'])
def get_dashboard(user_id):
    try:
        total  = Analysis.query.filter_by(user_id=user_id).count()
        latest = Analysis.query.filter_by(user_id=user_id)\
            .order_by(Analysis.created_at.desc()).first()
        latest_data = None
        if latest:
            latest_data = {
                'id': latest.id, 'gender': latest.gender,
                'skin_tone': latest.skin_tone, 'best_color': latest.best_color,
                'style_personality': latest.style_personality,
                'created_at': latest.created_at.strftime('%d %b %Y, %I:%M %p')
                if latest.created_at else None
            }
        return jsonify({'total_analyses': total, 'latest': latest_data}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/', methods=['GET'])
def health():
    return jsonify({'status': 'Ai Vastra API running'}), 200


try:
    with app.app_context():
        db.create_all()
except Exception as e:
    print(f"Warning: Could not create database tables: {e}")


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=False, host='0.0.0.0', port=port)

