"""Build the report from docs/LAPORAN.md and docs/identitas.json.
Usage: python3 -m pip install reportlab pillow; python3 tool/build_report.py
"""
from pathlib import Path
import re, json, html
from reportlab.pdfgen import canvas
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    BaseDocTemplate, PageTemplate, Frame, Paragraph, Spacer, PageBreak,
    Table, TableStyle, Image, KeepTogether, Preformatted,
)
from reportlab.platypus.tableofcontents import TableOfContents

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / 'docs'
OUT = DOCS / 'Laporan_UTS_Seduh_Surabaya.pdf'
IDENTITY = json.loads((DOCS / 'identitas.json').read_text())
FONT_DIR = Path('/usr/share/fonts/liberation')
# Override these paths on another OS if Liberation fonts are not installed.
for family, filename in [('Serif', 'LiberationSerif-Regular.ttf'),
    ('SerifB', 'LiberationSerif-Bold.ttf'), ('SerifI', 'LiberationSerif-Italic.ttf'),
    ('Mono', 'LiberationMono-Regular.ttf')]:
    path = FONT_DIR / filename
    if not path.exists():
        raise SystemExit('Install Liberation fonts or adjust FONT_DIR in this script.')
    pdfmetrics.registerFont(TTFont(family, str(path)))
pdfmetrics.registerFontFamily('Serif', normal='Serif', bold='SerifB', italic='SerifI', boldItalic='SerifB')
INK = colors.HexColor('#28231F')
BROWN = colors.HexColor('#6D4935')
PALE = colors.HexColor('#F4F1EB')
LINE = colors.HexColor('#DAD3C7')
W, H = A4
LEFT, RIGHT, TOP, BOTTOM = 30*mm, 25*mm, 24*mm, 23*mm
WIDTH = W - LEFT - RIGHT
styles = {
    'body': ParagraphStyle('body', fontName='Serif', fontSize=11, leading=15,
        alignment=TA_JUSTIFY, textColor=INK, spaceAfter=8),
    'h1': ParagraphStyle('h1', fontName='SerifB', fontSize=15, leading=20,
        spaceBefore=8, spaceAfter=20, keepWithNext=True),
    'h2': ParagraphStyle('h2', fontName='SerifB', fontSize=12.5, leading=17,
        spaceBefore=15, spaceAfter=10, keepWithNext=True),
    'h3': ParagraphStyle('h3', fontName='SerifB', fontSize=11.5, leading=16,
        spaceBefore=14, spaceAfter=8, keepWithNext=True),
    'caption': ParagraphStyle('caption', fontName='SerifI', fontSize=9.5, leading=13,
        alignment=TA_CENTER, spaceBefore=7, spaceAfter=14),
    'cell': ParagraphStyle('cell', fontName='Serif', fontSize=9.5, leading=12.5),
    'cellhead': ParagraphStyle('cellhead', fontName='SerifB', fontSize=9.5, leading=12.5,
        textColor=colors.white),
    'code': ParagraphStyle('code', fontName='Mono', fontSize=8.0, leading=11.5,
        backColor=PALE, borderPadding=9, spaceBefore=4, spaceAfter=13),
    'cover': ParagraphStyle('cover', fontName='SerifB', fontSize=16, leading=22,
        alignment=TA_CENTER),
    'center': ParagraphStyle('center', fontName='Serif', fontSize=12, leading=19,
        alignment=TA_CENTER),
}

def inline(text):
    s = html.escape(text)
    s = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', s)
    s = re.sub(r'`([^`]+)`', r'<font name="Mono" size="9">\1</font>', s)
    return s

class ReportDoc(BaseDocTemplate):
    def afterFlowable(self, flowable):
        if isinstance(flowable, Paragraph) and getattr(flowable, 'toc_level', None) is not None:
            title = flowable.getPlainText()
            key = 'toc-' + str(getattr(flowable, 'toc_key', ''))
            self.canv.bookmarkPage(key)
            self.notify('TOCEntry', (flowable.toc_level, title, self.page, key))

def decorate(c, doc):
    c.saveState()
    if doc.page > 1:
        c.setStrokeColor(LINE)
        c.setLineWidth(.5)
        c.line(LEFT, H - 17*mm, W - RIGHT, H - 17*mm)
        c.setFont('Serif', 8)
        c.setFillColor(BROWN)
        c.drawString(LEFT, H - 14*mm, 'SEDUH SURABAYA')
        c.drawRightString(W - RIGHT, H - 14*mm, 'LAPORAN UTS PEMROGRAMAN MOBILE')
        c.setFillColor(INK)
        c.setFont('Serif', 10)
        c.drawCentredString(W/2, 13*mm, str(doc.page))
    c.restoreState()

def cover():
    p = IDENTITY
    story = [Spacer(1, 14*mm), Paragraph('LAPORAN UJIAN TENGAH SEMESTER', styles['cover']),
        Spacer(1, 3*mm), Paragraph('PEMROGRAMAN MOBILE', styles['cover']),
        Spacer(1, 15*mm), Paragraph('SEDUH SURABAYA', styles['cover']),
        Spacer(1, 3*mm), Paragraph('Aplikasi Pencarian Kafe Berbasis Flutter dan REST API', styles['center']),
        Spacer(1, 15*mm)]
    logo = Path(p['logo_path']) if p.get('logo_path') else None
    if logo and not logo.is_absolute(): logo = ROOT / logo
    if logo and logo.exists():
        image = Image(str(logo), width=35*mm, height=35*mm, kind='proportional')
        image.hAlign='CENTER'
        story.append(image)
    else:
        placeholder = Table([[Paragraph('[LOGO FAKULTAS]', styles['center'])]], colWidths=[40*mm], rowHeights=[35*mm])
        placeholder.setStyle(TableStyle([('BOX',(0,0),(-1,-1),.8,LINE),('VALIGN',(0,0),(-1,-1),'MIDDLE')]))
        placeholder.hAlign='CENTER'
        story.append(placeholder)
    story += [Spacer(1, 14*mm), Paragraph('Disusun oleh:', styles['center']),
        Spacer(1, 3*mm), Paragraph(inline(p['nama']), styles['center']),
        Paragraph('NIM: ' + inline(p['nim']), styles['center']),
        Paragraph('Kelas: ' + inline(p['kelas']), styles['center']),
        Spacer(1, 19*mm)]
    for field in ['jurusan','fakultas','kampus','tahun']:
        story.append(Paragraph(inline(p[field]), styles['center']))
    if any('[' in p.get(k,'') for k in ['nama','nim','kelas','jurusan','fakultas','kampus']):
        story += [Spacer(1, 10*mm), Paragraph('DRAF - identitas dan logo belum dilengkapi',
            ParagraphStyle('draft', parent=styles['caption'], textColor=BROWN))]
    return story

def wrap_code(line, max_width):
    # Wrap only for print; source remains unchanged in Markdown.
    if pdfmetrics.stringWidth(line,'Mono',8) <= max_width:
        return [line]
    out=[]
    prefix = len(line) - len(line.lstrip())
    while pdfmetrics.stringWidth(line,'Mono',8) > max_width:
        limit = min(len(line), int(max_width / 4.8))
        cut = line.rfind(' ', max(0,limit//2),limit)
        if cut <= 0: cut=limit
        out.append(line[:cut])
        line = ' '*(min(prefix+2,8)) + line[cut:].lstrip()
    return out+[line]

def parse_body():
    text = (DOCS/'LAPORAN.md').read_text()
    text = text[text.index('# BAB I.'):]
    lines=text.splitlines(); result=[]; i=0; nhead=0
    while i<len(lines):
        line=lines[i].strip()
        if not line:
            i+=1;continue
        if line.startswith('```'):
            i+=1; code=[]
            while i<len(lines) and not lines[i].startswith('```'):
                code.extend(wrap_code(lines[i].rstrip(),WIDTH-20));i+=1
            result.append(KeepTogether([Preformatted('\n'.join(code), styles['code'])]))
            i+=1;continue
        if line.startswith('#'):
            level=len(line)-len(line.lstrip('#'))
            title=line[level:].strip()
            if level==1 and result:result.append(PageBreak())
            h=Paragraph(inline(title),styles['h'+str(min(level,3))])
            if level<=2:
                h.toc_level=level-1;h.toc_key=nhead;nhead+=1
            result.append(h);i+=1;continue
        if line.startswith('|'):
            rows=[]
            while i<len(lines) and lines[i].lstrip().startswith('|'):
                row=[c.strip() for c in lines[i].strip().strip('|').split('|')]
                if not all(re.fullmatch(r'[-: ]+',v) for v in row):rows.append(row)
                i+=1
            count=len(rows[0]); ratios={2:[.35,.65],3:[.23,.19,.58],4:[.24,.09,.55,.12]}.get(count,[1/count]*count)
            # Special-case result table for more balanced column widths.
            if count==4 and rows[0][0]=='Kelompok':ratios=[.23,.09,.55,.13]
            data=[[Paragraph(inline(c),styles['cellhead' if r==0 else 'cell']) for c in row] for r,row in enumerate(rows)]
            table=Table(data,colWidths=[WIDTH*x for x in ratios],repeatRows=1,hAlign='LEFT')
            table.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),BROWN),
                ('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.white,PALE]),
                ('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),7),
                ('RIGHTPADDING',(0,0),(-1,-1),7),('TOPPADDING',(0,0),(-1,-1),7),
                ('BOTTOMPADDING',(0,0),(-1,-1),7),('LINEBELOW',(0,0),(-1,0),.6,BROWN),
                ('LINEBELOW',(0,1),(-1,-1),.25,LINE)]))
            result += [table,Spacer(1,11)];continue
        image = re.fullmatch(r'!\[(.*?)\]\((.*?)\)',line)
        if image:
            caption,path=image.groups();file=DOCS/path
            if not file.exists():raise FileNotFoundError(file)
            from PIL import Image as PILImage
            with PILImage.open(file) as im:iw,ih=im.size
            height=min(280,ih/iw*WIDTH);width=height*iw/ih
            fig=Image(str(file),width=width,height=height);fig.hAlign='CENTER'
            result.append(KeepTogether([Spacer(1,7),fig,Paragraph(inline(caption),styles['caption'])]))
            i+=1;continue
        para=[line];i+=1
        while i<len(lines) and lines[i].strip() and not lines[i].startswith(('#','|','```','![')):
            para.append(lines[i].strip());i+=1
        result.append(KeepTogether([Paragraph(inline(' '.join(para)),styles['body'])]))
    return result

if __name__=='__main__':
    doc=ReportDoc(str(OUT),pagesize=A4,leftMargin=LEFT,rightMargin=RIGHT,topMargin=TOP,bottomMargin=BOTTOM,
        title='Laporan UTS - Seduh Surabaya',author=IDENTITY['nama'])
    frame=Frame(LEFT,BOTTOM,WIDTH,H-TOP-BOTTOM,id='body',leftPadding=0,rightPadding=0,topPadding=0,bottomPadding=0)
    doc.addPageTemplates(PageTemplate(id='normal',frames=frame,onPage=decorate))
    toc=TableOfContents()
    toc.levelStyles=[ParagraphStyle('toc1',fontName='SerifB',fontSize=11,leading=20,spaceBefore=8),
        ParagraphStyle('toc2',fontName='Serif',fontSize=10.5,leading=17,leftIndent=14)]
    story=cover()+[PageBreak(),Paragraph('DAFTAR ISI',styles['h1']),toc,PageBreak()]+parse_body()
    doc.multiBuild(story)
    print(OUT)
