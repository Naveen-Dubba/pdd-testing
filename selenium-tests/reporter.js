const ExcelJS = require('exceljs');
const path = require('path');
const fs = require('fs');

async function generateReport(testResults, platform = 'Web') {
  const reportsDir = path.join(__dirname, 'reports');
  if (!fs.existsSync(reportsDir)) {
    fs.mkdirSync(reportsDir, { recursive: true });
  }

  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const outputPath = path.join(reportsDir, `${platform.toLowerCase()}_test_report_${timestamp}.xlsx`);

  const workbook = new ExcelJS.Workbook();
  workbook.creator = 'Selenium Web Automator';
  workbook.lastModifiedBy = 'Selenium Web Automator';
  workbook.created = new Date();

  // 1. SUMMARY SHEET
  const wsSummary = workbook.addWorksheet('Summary', { views: [{ showGridLines: true }] });
  
  const total = testResults.length;
  const passed = testResults.filter(t => t.status === 'PASS').length;
  const failed = total - passed;
  const overall = failed === 0 && total > 0 ? 'PASS' : 'FAIL';
  const duration = testResults.reduce((acc, t) => acc + (t.duration || 0), 0);

  // Title
  wsSummary.mergeCells('A1:D1');
  const titleCell = wsSummary.getCell('A1');
  titleCell.value = `Vastra ${platform} E2E Test Execution Report`;
  titleCell.font = { name: 'Calibri', size: 16, bold: true, color: { argb: 'FFFFFFFF' } };
  titleCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '1F497D' } };
  titleCell.alignment = { horizontal: 'center', vertical: 'middle' };
  wsSummary.getRow(1).height = 40;

  // Metadata
  const metadata = [
    ['Execution Timestamp', new Date().toLocaleString()],
    ['Automation Engine', 'Selenium WebDriver (Chrome)'],
    ['Target Platform', `Vastra ${platform} App`],
    ['Test Environment', 'Localhost / CI Pipeline']
  ];

  metadata.forEach((row, i) => {
    const rIdx = i + 3;
    wsSummary.getCell(`A${rIdx}`).value = row[0];
    wsSummary.getCell(`B${rIdx}`).value = row[1];
    wsSummary.getCell(`A${rIdx}`).font = { bold: true };
    wsSummary.getCell(`A${rIdx}`).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'DCE6F1' } };
    wsSummary.getCell(`A${rIdx}`).border = { top: { style: 'thin' }, left: { style: 'thin' }, bottom: { style: 'thin' }, right: { style: 'thin' } };
    wsSummary.getCell(`B${rIdx}`).border = { top: { style: 'thin' }, left: { style: 'thin' }, bottom: { style: 'thin' }, right: { style: 'thin' } };
  });

  // Stats table
  wsSummary.getCell('A8').value = 'Execution Stat';
  wsSummary.getCell('B8').value = 'Value';
  wsSummary.getCell('A8').font = { bold: true, color: { argb: 'FFFFFFFF' } };
  wsSummary.getCell('B8').font = { bold: true, color: { argb: 'FFFFFFFF' } };
  wsSummary.getCell('A8').fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '1F497D' } };
  wsSummary.getCell('B8').fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '1F497D' } };

  const stats = [
    ['Total Test Cases Run', total],
    ['Passed Cases', passed],
    ['Failed Cases', failed],
    ['Total Duration (seconds)', (duration / 1000).toFixed(2)],
    ['Overall Status', overall]
  ];

  stats.forEach((stat, i) => {
    const rIdx = i + 9;
    wsSummary.getCell(`A${rIdx}`).value = stat[0];
    wsSummary.getCell(`B${rIdx}`).value = stat[1];
    wsSummary.getCell(`A${rIdx}`).font = { bold: true };
    
    wsSummary.getCell(`A${rIdx}`).border = { top: { style: 'thin' }, left: { style: 'thin' }, bottom: { style: 'thin' }, right: { style: 'thin' } };
    wsSummary.getCell(`B${rIdx}`).border = { top: { style: 'thin' }, left: { style: 'thin' }, bottom: { style: 'thin' }, right: { style: 'thin' } };

    if (stat[0] === 'Overall Status') {
      const isPass = stat[1] === 'PASS';
      wsSummary.getCell(`B${rIdx}`).fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: isPass ? 'C6EFCE' : 'FFC7CE' }
      };
      wsSummary.getCell(`B${rIdx}`).font = {
        bold: true,
        color: { argb: isPass ? '006100' : '9C0006' }
      };
    }
  });

  // 2. DETAILS SHEET
  const wsDetails = workbook.addWorksheet('Test Details', { views: [{ showGridLines: true }] });
  
  const headers = [
    'Index', 'Test ID', 'Screen Component', 'Test Type', 'Description', 'Status', 'Duration (ms)', 'Error Messages', 'Screenshot Path'
  ];

  wsDetails.getRow(1).values = headers;
  wsDetails.getRow(1).height = 25;
  headers.forEach((h, i) => {
    const cell = wsDetails.getCell(1, i + 1);
    cell.font = { name: 'Calibri', size: 11, bold: true, color: { argb: 'FFFFFFFF' } };
    cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '1F497D' } };
    cell.alignment = { horizontal: 'center', vertical: 'middle', wrapText: true };
    cell.border = { top: { style: 'thin' }, left: { style: 'thin' }, bottom: { style: 'thin' }, right: { style: 'thin' } };
  });

  testResults.forEach((test, idx) => {
    const rIdx = idx + 2;
    const values = [
      idx + 1,
      test.id || `TS-${rIdx - 1}`,
      test.screen || 'General',
      test.type || 'Functional',
      test.description || 'No description',
      test.status || 'FAIL',
      test.duration || 0,
      test.error || '',
      test.screenshot || ''
    ];

    wsDetails.getRow(rIdx).values = values;
    wsDetails.getRow(rIdx).height = 20;

    for (let c = 1; c <= headers.length; c++) {
      const cell = wsDetails.getCell(rIdx, c);
      cell.font = { name: 'Calibri', size: 11 };
      cell.border = { top: { style: 'thin' }, left: { style: 'thin' }, bottom: { style: 'thin' }, right: { style: 'thin' } };
      cell.alignment = { vertical: 'middle' };
      
      if (c === 1 || c === 2 || c === 6) {
        cell.alignment = { horizontal: 'center', vertical: 'middle' };
      }
      if (c === 7) {
        cell.alignment = { horizontal: 'right', vertical: 'middle' };
      }
      
      if (c === 6) {
        const isPass = test.status === 'PASS';
        cell.fill = {
          type: 'pattern',
          pattern: 'solid',
          fgColor: { argb: isPass ? 'C6EFCE' : 'FFC7CE' }
        };
        cell.font = {
          bold: true,
          color: { argb: isPass ? '006100' : '9C0006' }
        };
      }
    }
  });

  // Auto column widths
  for (let c = 1; c <= headers.length; c++) {
    const col = wsDetails.getColumn(c);
    let maxLen = 0;
    col.eachCell({ includeEmpty: true }, (cell) => {
      const valStr = cell.value ? cell.value.toString() : '';
      if (valStr.length > maxLen) maxLen = valStr.length;
    });
    col.width = Math.max(maxLen + 3, 12);
  }

  for (let c = 1; c <= 2; c++) {
    const col = wsSummary.getColumn(c);
    let maxLen = 0;
    col.eachCell({ includeEmpty: true }, (cell) => {
      const valStr = cell.value ? cell.value.toString() : '';
      if (valStr.length > maxLen) maxLen = valStr.length;
    });
    col.width = Math.max(maxLen + 3, 15);
  }

  await workbook.xlsx.writeFile(outputPath);
  console.log(`Excel test report saved successfully to: ${outputPath}`);
  return outputPath;
}

module.exports = { generateReport };
