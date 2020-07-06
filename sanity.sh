dodgy --ignore paths venv env migrations scripts
isort -rc --atomic ./ -sg "*/migrations/*.py" -sg "*/docs/*.py"
pydocstyle --config=./.pydocstylerc
pycodestyle ./ --config=./.pycodestylerc