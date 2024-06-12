#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["CarCareHub_/CarCareHub_.API.csproj", "CarCareHub_.API/"]
RUN dotnet restore "CarCareHub_/CarCareHub_.API.csproj"
COPY . .
WORKDIR "/src/CarCareHub_.API"
RUN dotnet build "CarCareHub_.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "CarCareHub_.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CarCareHub_.API.dll"]