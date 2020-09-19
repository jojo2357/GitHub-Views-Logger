'Program that creates charts from data. MUST BE CALLED FROM COMMAND LINE
'Parameters: Clones/Views, Repo Name
'This program uses qb64's built-in graphics library to draw a graph
'Then, it takes a screenshot of the destop and saves it
'.jpg not supported to my awareness, but if it is a problem,
'open it in pictures and take a screenshot :)

_TITLE "ChartMaker" 'Names the window. How cute!

TYPE timeStamp
  date AS _UNSIGNED INTEGER '0 = 2020/01/01
  views AS _UNSIGNED LONG
  uniques AS _UNSIGNED LONG
END TYPE

REM parameter 1 = views/clones, 2 = name
commandUsed$ = RTRIM$(LTRIM$(COMMAND$))

DIM args(1 TO 2) AS STRING
args(1) = LTRIM$(RTRIM$(LEFT$(commandUsed$, INSTR(commandUsed$, " ")))) 'Clones/Views
args(2) = LTRIM$(RTRIM$(RIGHT$(commandUsed$, LEN(commandUsed$) - LEN(args(1))))) 'Repo name

OPEN _CWD$ + "\ParsedData\" + args(1) + "\" + args(2) + ".csv" FOR INPUT AS #1 'Raw data file
LINE INPUT #1, ignoreFirstRead$
IF EOF(1) THEN SYSTEM 'quits if there is only one line
handle& = _NEWIMAGE(_DESKTOPWIDTH, _DESKTOPHEIGHT, 256) 'We want to do this asap, and this is asap
SCREEN 13 'creates the screen and moves it to top left corner of the desktop so that a screenshot can be taken
'$SCREENHIDE
_DEST handle&
DO
  lines = lines + 1 'counts the lines
  LINE INPUT #1, ignoreFirstRead$
LOOP UNTIL EOF(1)
CLOSE #1

DIM timestamps(1 TO lines) AS timeStamp 'Has to count first because it's faster and easier than using dynamic arrays
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
  timestamps(timestampCounter).date = extractDateNumber(LEFT$(lineIn$, INSTR(lineIn$, ",") - 1)) 'Data parsing, just believe that it works or go on the qb64 wiki
  lineIn$ = RIGHT$(lineIn$, LEN(lineIn$) - INSTR(lineIn$, ","))
  timestamps(timestampCounter).views = VAL(LEFT$(lineIn$, INSTR(lineIn$, ",")))
  lineIn$ = RIGHT$(lineIn$, LEN(lineIn$) - INSTR(lineIn$, ","))
  timestamps(timestampCounter).uniques = VAL(lineIn$)
  IF timestamps(timestampCounter).views > mostViews THEN 'Keeps track of record # of views and uniques for use in scaling the chart
    mostViews = timestamps(timestampCounter).views
  END IF
  IF timestamps(timestampCounter).uniques > mostUniques THEN
    mostUniques = timestamps(timestampCounter).uniques
  END IF
LOOP UNTIL EOF(1)
CLOSE #1

zeroDay = timestamps(1).date
finalDay = timestamps(timestampCounter).date

LOCATE 3, (_WIDTH / 16) - LEN(RTRIM$(LTRIM$(args(1) + " of " + args(2) + " between " + dayOne$ + " and " + mostRecent$))) / 2
PRINT args(1); " of "; args(2); " between "; dayOne$; " and "; mostRecent$ 'Title
LOCATE 4, ((_WIDTH / 16) - (LEN("On the left are " + args(1) + " represented in green and on the right are unique " + args(1) + " represented in blue")) / 2)
PRINT "On the left are "; args(1); " represented in green and on the right are unique "; args(1); " represented in blue" 'Axis labels

LINE (83, _HEIGHT - 200)-(_WIDTH - 83, 100), _RGB(54, 57, 63), BF
FOR verticalLineDrawer = 1 TO finalDay - zeroDay - 1
  LINE (83 + ((_WIDTH - 2 * 83) * (verticalLineDrawer) / (finalDay - zeroDay)), _HEIGHT - 201)-(83 + ((_WIDTH - 2 * 83) * (verticalLineDrawer) / (finalDay - zeroDay)), 101), _RGB(32, 34, 37) 'Vertical lines at each date
NEXT

FOR tabs = 1 TO 3 'Numberic axis labels
  LOCATE (_HEIGHT - 200 - ((_HEIGHT - 300) * tabs / 3)) / 16, 50 / 8
  IF (INT(tabs * mostViews / 3) > 0 AND INT(tabs * mostViews / 3) > INT((mostViews * (tabs - 1)) / 3)) OR tabs = 3 THEN
    PRINT INT(tabs * mostViews / 3)
  END IF
  LINE (83, (_HEIGHT - 200 - ((_HEIGHT - 300) * tabs / 3)))-(_WIDTH - 83, (_HEIGHT - 200 - (_HEIGHT - 300) * tabs / 3)), _RGB(32, 34, 37)
  LOCATE (_HEIGHT - 200 - (_HEIGHT - 300) * tabs / 3) / 16, (_WIDTH - 75) / 8
  IF (INT(tabs * mostUniques / 3) > 0 AND INT(tabs * mostUniques / 3) > INT((mostUniques * (tabs - 1)) / 3)) OR tabs = 3 THEN
    PRINT INT(tabs * mostUniques / 3)
  END IF
NEXT

LINE (83, _HEIGHT - 200 - (_HEIGHT - 300) * (timestamps(1).views / mostViews))-(83, _HEIGHT - 200 - (_HEIGHT - 300) * (timestamps(1).views / mostViews))
FOR chartMaker = 1 TO timestampCounter 'Plot view lines
  IF chartMaker > 1 THEN
    IF timestamps(chartMaker - 1).date <> timestamps(chartMaker).date - 1 THEN
      LINE -(83 + ((_WIDTH - 166) * (timestamps(chartMaker).date - 1 - zeroDay) / (finalDay - zeroDay)), _HEIGHT - 201), _RGB(0, 175, 0)
    END IF
  END IF
  LINE -(83 + ((_WIDTH - 166) * (timestamps(chartMaker).date - zeroDay) / (finalDay - zeroDay)), _HEIGHT - 200 - (_HEIGHT - 300) * (timestamps(chartMaker).views / mostViews)), _RGB(0, 175, 0)
  IF chartMaker < timestampCounter THEN
    IF timestamps(chartMaker + 1).date <> timestamps(chartMaker).date + 1 THEN
      LINE -(83 + ((_WIDTH - 166) * (timestamps(chartMaker).date + 1 - zeroDay) / (finalDay - zeroDay)), _HEIGHT - 201), _RGB(0, 175, 0)
    END IF
  END IF
NEXT

LINE (83, _HEIGHT - 200 - (_HEIGHT - 300) * (timestamps(1).uniques / mostUniques))-(83, _HEIGHT - 200 - (_HEIGHT - 300) * (timestamps(1).uniques / mostUniques))
FOR chartMaker = 1 TO timestampCounter 'Plot unique lines
  IF chartMaker > 1 THEN
    IF timestamps(chartMaker - 1).date <> timestamps(chartMaker).date - 1 THEN
      LINE -(83 + ((_WIDTH - 166) * (timestamps(chartMaker).date - 1 - zeroDay) / (finalDay - zeroDay)), _HEIGHT - 201), _RGB(0, 0, 175)
    END IF
  END IF
  LINE -(83 + ((_WIDTH - 166) * (timestamps(chartMaker).date - zeroDay) / (finalDay - zeroDay)), _HEIGHT - 200 - (_HEIGHT - 300) * (timestamps(chartMaker).uniques / mostUniques)), _RGB(0, 0, 175)
  IF chartMaker < timestampCounter THEN
    IF timestamps(chartMaker + 1).date <> timestamps(chartMaker).date + 1 THEN
      LINE -(83 + ((_WIDTH - 166) * (timestamps(chartMaker).date + 1 - zeroDay) / (finalDay - zeroDay)), _HEIGHT - 201), _RGB(0, 0, 175)
    END IF
  END IF
NEXT

FOR chartMaker = 1 TO timestampCounter 'Plot points
  CIRCLE (83 + ((_WIDTH - 166) * (timestamps(chartMaker).date - zeroDay) / (finalDay - zeroDay)), _HEIGHT - 200 - (_HEIGHT - 300) * (timestamps(chartMaker).views / mostViews)), 5, _RGB(0, 225, 0)
  PAINT (83 + ((_WIDTH - 166) * (timestamps(chartMaker).date - zeroDay) / (finalDay - zeroDay)), _HEIGHT - 200 - (_HEIGHT - 300) * (timestamps(chartMaker).views / mostViews)), _RGB(0, 225, 0)
  CIRCLE (83 + ((_WIDTH - 166) * (timestamps(chartMaker).date - zeroDay) / (finalDay - zeroDay)), _HEIGHT - 200 - (_HEIGHT - 300) * (timestamps(chartMaker).uniques / mostUniques)), 5, _RGB(0, 0, 225)
  PAINT (83 + ((_WIDTH - 166) * (timestamps(chartMaker).date - zeroDay) / (finalDay - zeroDay)), _HEIGHT - 200 - (_HEIGHT - 300) * (timestamps(chartMaker).uniques / mostUniques)), _RGB(0, 0, 225)
NEXT

saveDir$ = _CWD$ + "\Charts\" + args(1) + "\" + args(2)
SaveImage handle&, saveDir$ 'save screenshot

SYSTEM

FUNCTION extractDateNumber (dateString$) 'IN: String in format YYYY-MM-DD | RETURN: days since zeroYear-zeroMonth-zeroDay
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

FUNCTION monthValue (monthNumber, yearNumber) 'IN: two numbers | RETURN: amount of days in that month in the given year
  SELECT CASE monthNumber
    CASE 1, 3, 5, 7, 8, 10, 12
      monthValue = 31
    CASE 2
      monthValue = yearValue(yearNumber) - 337
    CASE 4, 6, 9, 11
      monthValue = 30
  END SELECT
END FUNCTION

FUNCTION yearValue (yearNumber) 'IN: one number | RETURN: amount of days in that year
  IF yearNumber MOD 4 = 0 THEN
    IF yearNumber MOD 100 = 0 THEN
      IF yearNumber MOD 400 = 0 THEN
        yearValue = 366
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
SUB SaveImage (image AS LONG, filename AS STRING) 'Yes, it does HAVE to save it as a .bmp, and if it is too much trouble, one can save the bmp as jpg afterwards.
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
