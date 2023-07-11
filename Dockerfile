FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_16.x  | bash -
RUN apt-get -y install nodejs

COPY . ./
RUN dotnet restore

RUN dotnet build "dotnet6.csproj" -c Release

RUN dotnet publish "dotnet6.csproj" -c Release -o publish


FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base

WORKDIR /app

COPY --from=build /app/publish .

RUN groupadd -g 2000 skgroup \
    && useradd -r -u 2000 -g 2000 sk \
    && chown -R sk:skgroup /app

USER sk

ENV ASPNETCORE_URLS http://*:5000

EXPOSE 5000
ENTRYPOINT ["dotnet", "dotnet6.dll"]