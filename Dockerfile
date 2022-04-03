FROM python:3.8
WORKDIR /app
COPY . /app
RUN pip install click==6.7 pandas scikit-learn Flask 


EXPOSE 5000
CMD python ./app.py
