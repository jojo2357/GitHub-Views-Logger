'Program that creates charts from data. MUST BE CALLED FROM COMMAND LINE
'Parameters: Clones/Views, Repo Name
'This program uses qb64's built-in graphics library to draw a graph
'Then, it takes a screenshot of the destop and saves it
'.jpg not supported to my awareness, but if it is a problem,
'open it in pictures and take a screenshot :)

'TODO: optimize for any given desktop size

_TITLE "ChartMaker"

'$SCREENHIDE

TYPE timeStamp
  date AS _UNSIGNED INTEGER '0 = 2020/01/01
  views AS _UNSIGNED LONG
  uniques AS _UNSIGNED LONG
END TYPE

REM parameter 1 = views/commits, 2 = name
commandUsed$ = RTRIM$(LTRIM$(COMMAND$))

DIM args(1 TO 2) AS STRING
args(1) = LTRIM$(RTRIM$(LEFT$(commandUsed$, INSTR(commandUsed$, " "))))
args(2) = LTRIM$(RTRIM$(RIGHT$(commandUsed$, LEN(commandUsed$) - LEN(args(1)))))

PRINT COMMAND$, args(1), args(2)
PRINT _CWD$ + "\ParsedData\" + args(1) + "\" + args(2) + ".csv"

OPEN _CWD$ + "\ParsedData\" + args(1) + "\" + args(2) + ".csv" FOR INPUT AS #1
LINE INPUT #1, ignoreFirstRead$
IF EOF(1) THEN SYSTEM
DO
  lines = lines + 1
  LINE INPUT #1, ignoreFirstRead$
LOOP UNTIL EOF(1)
CLOSE #1

DIM timestamps(1 TO lines) AS timeStamp

OPEN _CWD$ + "\ParsedData\" + args(1) + "\" + args(2) + ".csv" FOR INPUT AS #1
LINE INPUT #1, ignoreFirstRead$
IF EOF(1) THEN END
DO
  timestampCounter = timestampCounter + 1
  LINE INPUT #1, lineIn$
  IF timestampCounter = 1 THEN
    dayOne$ = LEFT$(lineIn$, INSTR(lineIn$, ",") - 1)
  END IF
  IF timestampCounter = lines THEN
    mostRecent$ = LEFT$(lineIn$, INSTR(lineIn$, ",") - 1)
  END IF
  timestamps(timestampCounter).date = extractDateNumber(LEFT$(lineIn$, INSTR(lineIn$, ",") - 1))
  lineIn$ = RIGHT$(lineIn$, LEN(lineIn$) - INSTR(lineIn$, ","))
  timestamps(timestampCounter).views = VAL(LEFT$(lineIn$, INSTR(lineIn$, ",")))
  lineIn$ = RIGHT$(lineIn$, LEN(lineIn$) - INSTR(lineIn$, ","))
  timestamps(timestampCounter).uniques = VAL(lineIn$)

  IF timestamps(timestampCounter).views > mostViews THEN
    mostViews = timestamps(timestampCounter).views
  END IF
  IF timestamps(timestampCounter).uniques > mostUniques THEN
    mostUniques = timestamps(timestampCounter).uniques
  END IF

LOOP UNTIL EOF(1)
CLOSE #1

handle& = _NEWIMAGE(1366, 768, 256)
SCREEN handle&
_SCREENMOVE 0, 0

zeroDay = timestamps(1).date
finalDay = timestamps(timestampCounter).date

LOCATE 3, (1366 / 16) - LEN(RTRIM$(LTRIM$(args(1) + " of " + args(2) + " between " + dayOne$ + " and " + mostRecent$))) / 2
PRINT args(1); " of "; args(2); " between "; dayOne$; " and "; mostRecent$
LOCATE 4, ((1366 / 16) - (LEN("On the left are " + args(1) + " represented in green and on the right are unique " + args(1) + " represented in blue")) / 2)
PRINT "On the left are "; args(1); " represented in green and on the right are unique "; args(1); " represented in blue"

LINE (83, 650)-(1283, 100), _RGB(54, 57, 63), BF
FOR verticalLineDrawer = 1 TO finalDay - zeroDay - 1
  LINE (83 + (1200 * (verticalLineDrawer) / (finalDay - zeroDay)), 649)-(83 + (1200 * (verticalLineDrawer) / (finalDay - zeroDay)), 101), _RGB(32, 34, 37)
NEXT

FOR tabs = 1 TO 3
  LOCATE (650 - (550 * tabs / 3)) / 16, 50 / 8
  IF (INT(tabs * mostViews / 3) > 0 AND INT(tabs * mostViews / 3) > INT((mostViews * (tabs - 1)) / 3)) OR tabs = 3 THEN
    PRINT INT(tabs * mostViews / 3)
  END IF
  LINE (83, (650 - (550 * tabs / 3)))-(1283, (650 - 550 * tabs / 3)), _RGB(32, 34, 37)
  LOCATE (650 - 550 * tabs / 3) / 16, 1300 / 8
  IF (INT(tabs * mostUniques / 3) > 0 AND INT(tabs * mostUniques / 3) > INT((mostUniques * (tabs - 1)) / 3)) OR tabs = 3 THEN
    PRINT INT(tabs * mostUniques / 3)
  END IF
NEXT


LINE (83, 650 - 550 * (timestamps(1).views / mostViews))-(83, 650 - 550 * (timestamps(1).views / mostViews))
FOR chartMaker = 1 TO timestampCounter
  IF chartMaker > 1 THEN
    IF timestamps(chartMaker - 1).date <> timestamps(chartMaker).date - 1 THEN
      LINE -(83 + (1200 * (timestamps(chartMaker).date - 1 - zeroDay) / (finalDay - zeroDay)), 649), _RGB(0, 175, 0)
    END IF
  END IF
  LINE -(83 + (1200 * (timestamps(chartMaker).date - zeroDay) / (finalDay - zeroDay)), 650 - 550 * (timestamps(chartMaker).views / mostViews)), _RGB(0, 175, 0)
  IF chartMaker < timestampCounter THEN
    IF timestamps(chartMaker + 1).date <> timestamps(chartMaker).date + 1 THEN
      LINE -(83 + (1200 * (timestamps(chartMaker).date + 1 - zeroDay) / (finalDay - zeroDay)), 649), _RGB(0, 175, 0)
    END IF
  END IF
NEXT

LINE (83, 650 - 550 * (timestamps(1).uniques / mostUniques))-(83, 650 - 550 * (timestamps(1).uniques / mostUniques))
FOR chartMaker = 1 TO timestampCounter
  IF chartMaker > 1 THEN
    IF timestamps(chartMaker - 1).date <> timestamps(chartMaker).date - 1 THEN
      LINE -(83 + (1200 * (timestamps(chartMaker).date - 1 - zeroDay) / (finalDay - zeroDay)), 649), _RGB(0, 0, 175)
    END IF
  END IF
  LINE -(83 + (1200 * (timestamps(chartMaker).date - zeroDay) / (finalDay - zeroDay)), 650 - 550 * (timestamps(chartMaker).uniques / mostUniques)), _RGB(0, 0, 175)
  IF chartMaker < timestampCounter THEN
    IF timestamps(chartMaker + 1).date <> timestamps(chartMaker).date + 1 THEN
      LINE -(83 + (1200 * (timestamps(chartMaker).date + 1 - zeroDay) / (finalDay - zeroDay)), 649), _RGB(0, 0, 175)
    END IF
  END IF
NEXT

FOR chartMaker = 1 TO timestampCounter
  CIRCLE (83 + (1200 * (timestamps(chartMaker).date - zeroDay) / (finalDay - zeroDay)), 650 - 550 * (timestamps(chartMaker).views / mostViews)), 5, _RGB(0, 225, 0)
  PAINT (83 + (1200 * (timestamps(chartMaker).date - zeroDay) / (finalDay - zeroDay)), 650 - 550 * (timestamps(chartMaker).views / mostViews)), _RGB(0, 225, 0)

  CIRCLE (83 + (1200 * (timestamps(chartMaker).date - zeroDay) / (finalDay - zeroDay)), 650 - 550 * (timestamps(chartMaker).uniques / mostUniques)), 5, _RGB(0, 0, 225)
  PAINT (83 + (1200 * (timestamps(chartMaker).date - zeroDay) / (finalDay - zeroDay)), 650 - 550 * (timestamps(chartMaker).uniques / mostUniques)), _RGB(0, 0, 225)
NEXT

DIM chart AS LONG
_DISPLAY
_DELAY (1)
chart = _SCREENIMAGE
saveDir$ = _CWD$ + "\Charts\" + args(1) + "\" + args(2)
SaveImage chart, saveDir$

SYSTEM

FUNCTION extractDateNumber (dateString$)
  dayNumber = 0
  zeroYear = 2020
  zeroMonth = 1
  zeroDay = 1
  year = VAL(LEFT$(dateString$, INSTR(dateString$, "-")))
  dateString$ = RIGHT$(dateString$, LEN(dateString$) - INSTR(dateString$, "-"))
  month = VAL(LEFT$(dateString$, INSTR(dateString$, "-")))
  dateString$ = RIGHT$(dateString$, LEN(dateString$) - INSTR(dateString$, "-"))
  day = VAL(RIGHT$(dateString$, LEN(dateString$) - INSTR(dateString$, "-")))
  IF year > zeroYear THEN
    FOR loopCounter = 1 TO year - zeroYear
      dayNumber = dayNumber + yearValue(zeroYear + loopCounter - 1)
    NEXT
  END IF
  IF month > zeroMonth THEN
    FOR loopCounter = 1 TO month - zeroMonth
      dayNumber = dayNumber + monthValue(zeroMonth + loopCounter - 1, year)
    NEXT
  END IF
  dayNumber = dayNumber + day - zeroDay
  extractDateNumber = dayNumber
END FUNCTION

FUNCTION monthValue (monthNumber, yearNumber)
  SELECT CASE monthNumber
    CASE 1, 3, 5, 7, 8, 10, 12
      monthValue = 31
    CASE 2
      monthValue = yearValue(yearNumber) - 337
    CASE 4, 6, 9, 11
      monthValue = 30
  END SELECT
END FUNCTION

FUNCTION yearValue (yearNumber)
  IF yearNumber MOD 4 = 0 THEN
    IF yearNumber MOD 100 = 0 THEN
      IF yearNumber MOD 400 = 0 THEN
        yearValue = 366
        RETURN
      ELSE
        yearValue = 365
      END IF
    ELSE
      yearValue = 366
    END IF
  ELSE
    yearValue = 365
  END IF
END FUNCTION

REM not my own work, but it works credit qb64.org/wiki/SVAEIMAGE

SUB SaveImage (image AS LONG, filename AS STRING)
  bytesperpixel& = _PIXELSIZE(image&)
  IF bytesperpixel& = 0 THEN PRINT "Text modes unsupported!": END
  IF bytesperpixel& = 1 THEN bpp& = 8 ELSE bpp& = 24
  x& = _WIDTH(image&)
  y& = _HEIGHT(image&)
  b$ = "BM????QB64????" + MKL$(40) + MKL$(x&) + MKL$(y&) + MKI$(1) + MKI$(bpp&) + MKL$(0) + "????" + STRING$(16, 0) 'partial BMP header info(???? to be filled later)
  IF bytesperpixel& = 1 THEN
    FOR c& = 0 TO 255 ' read BGR color settings from JPG image + 1 byte spacer(CHR$(0))
      cv& = _PALETTECOLOR(c&, image&) ' color attribute to read.
      b$ = b$ + CHR$(_BLUE32(cv&)) + CHR$(_GREEN32(cv&)) + CHR$(_RED32(cv&)) + CHR$(0) 'spacer byte
    NEXT
  END IF
  MID$(b$, 11, 4) = MKL$(LEN(b$)) ' image pixel data offset(BMP header)
  lastsource& = _SOURCE
  _SOURCE image&
  IF ((x& * 3) MOD 4) THEN padder$ = STRING$(4 - ((x& * 3) MOD 4), 0)
  FOR py& = y& - 1 TO 0 STEP -1 ' read JPG image pixel color data
    r$ = ""
    FOR px& = 0 TO x& - 1
      c& = POINT(px&, py&) 'POINT 32 bit values are large LONG values
      IF bytesperpixel& = 1 THEN r$ = r$ + CHR$(c&) ELSE r$ = r$ + LEFT$(MKL$(c&), 3)
    NEXT px&
    d$ = d$ + r$ + padder$
  NEXT py&
  _SOURCE lastsource&
  MID$(b$, 35, 4) = MKL$(LEN(d$)) ' image size(BMP header)
  b$ = b$ + d$ ' total file data bytes to create file
  MID$(b$, 3, 4) = MKL$(LEN(b$)) ' size of data file(BMP header)
  IF LCASE$(RIGHT$(filename$, 4)) <> ".bmp" THEN ext$ = ".bmp"
  f& = FREEFILE
  OPEN filename$ + ext$ FOR OUTPUT AS #f&: CLOSE #f& ' erases an existing file
  OPEN filename$ + ext$ FOR BINARY AS #f&
  PUT #f&, , b$
  CLOSE #f&
END SUB
