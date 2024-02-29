#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["CarCareHub_/CarCareHub_.csproj", "CarCareHub_/"]
RUN dotnet restore "CarCareHub_/CarCareHub_.csproj"
COPY . .
WORKDIR "/src/CarCareHub_"
RUN dotnet build "CarCareHub_.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "CarCareHub_.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CarCareHub_.dll"]