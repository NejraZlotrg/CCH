using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
//using CarCareHub.Model;


using CarCareHub.Services.Database;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<IProizvodiService, ProizvodiService>();

builder.Services.AddTransient<IFirmaAutodijelovaService, FirmaAutodijelovaService>();
builder.Services.AddTransient<IGradService, GradService>();
//builder.Services.AddTransient<  IService<CarCareHub.Model.Grad>, GradService>();
//builder.Services.AddTransient <IService<CarCareHub.Model.Zaposlenik, ZaposlenikSearchObject>, BaseService<CarCareHub.Model.Zaposlenik, 
//    CarCareHub.Services.Database.Zaposlenik, ZaposlenikSearchObject>>();

builder.Services.AddTransient<IZaposlenikService, ZaposlenikService>();




builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddAutoMapper(typeof(IGradService));
builder.Services.AddAutoMapper(typeof(IFirmaAutodijelovaService));
builder.Services.AddAutoMapper(typeof(IZaposlenikService));


var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<CchV2AliContext>(options =>
options.UseSqlServer(connectionString));
var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
