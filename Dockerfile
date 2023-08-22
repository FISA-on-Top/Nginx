FROM nginx:latest 

RUN rm -rf /etc/nginx/conf.d
COPY ./conf /etc/nginx

#80포트 오픈하고 nginx 실행
EXPOSE 80
CMD [ "nginx", "-g", "daemon off;" ]
