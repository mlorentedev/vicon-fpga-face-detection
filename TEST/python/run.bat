call .venv\Scripts\activate.bat || exit /b !ERRORLEVEL!
call python test_ft232.py || exit /b !ERRORLEVEL!
