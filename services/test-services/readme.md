

docker pull postgres

docker run --name postgresql -e POSTGRES_USER=myuser -e POSTGRES_PASSWORD=mypassword -p 5432:5432 -v /Users/srinathrangaramanujam/Documents/Srinath/deliveryhero/src/dh_projects/mesh/playground/actualwork/test:/var/lib/postgresql/data -d postgres
