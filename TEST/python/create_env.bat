call python -m venv .venv || exit /b !ERRORLEVEL!
call .venv\Scripts\activate.bat || exit /b !ERRORLEVEL!
call python -m pip install pylibftdi || exit /b !ERRORLEVEL!
call python -m pip install ftd2xx || exit /b !ERRORLEVEL!