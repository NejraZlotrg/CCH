using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
//using CarCareHub.Model;


using CarCareHub.Services.Database;
using CarCareHub.Services.ProizvodiStateMachine;
using CarCareHub_;
using CarCareHub_.Errors;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<IProizvodiService, ProizvodiService>();

builder.Services.AddTransient<IFirmaAutodijelovaService, FirmaAutodijelovaService>();
builder.Services.AddTransient<IGradService, GradService>();
//builder.Services.AddTransient<  IService<CarCareHub.Model.Grad>, GradService>();
//builder.Services.AddTransient<IService<CarCareHub.Model.Zaposlenik, ZaposlenikSearchObject>, BaseService<CarCareHub.Model.Zaposlenik,
//    CarCareHub.Services.Database.Zaposlenik, ZaposlenikSearchObject>>();

//RADIbuilder.Services.AddTransient<ICRUDService<CarCareHub.Model.Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate>, ZaposlenikService>();
builder.Services.AddTransient<ICRUDService<CarCareHub.Model.Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate>, BaseCRUDService<CarCareHub.Model.Zaposlenik, CarCareHub.Services.Database.Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate>>();



// Ostali servisi
//builder.Services.AddTransient<IZaposlenikService, ZaposlenikService>();

builder.Services.AddTransient<BaseState>();
builder.Services.AddTransient<InitialProductState>();
builder.Services.AddTransient<DraftProductState>();
builder.Services.AddTransient<ActiveProductState>();


builder.Services.AddControllers( x => { x.Filters.Add<ErrorFilter>(); });
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("basicAuth", new Microsoft.OpenApi.Models.OpenApiSecurityScheme()
    {
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "basic"
});
c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement() {
        {
            new OpenApiSecurityScheme
            {
                Reference=new OpenApiReference
                {
                    Type=ReferenceType.SecurityScheme, Id="basicAuth"
                }
            },
            new string []{}
        } });
});

builder.Services.AddAutoMapper(typeof(IGradService));
builder.Services.AddAutoMapper(typeof(IFirmaAutodijelovaService));
builder.Services.AddAutoMapper(typeof(IZaposlenikService));
builder.Services.AddAuthentication("BasicAuthentication").AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

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

app.UseAuthentication();


app.MapControllers();


//using (var scope = app.Services.CreateScope())
//{
//    var dataContext = scope.ServiceProvider.GetRequiredService<CchV2AliContext>();

//    // dataContext.Database.EnsureCreated();
//    var conn = dataContext.Database.GetConnectionString();
//    dataContext.Database.Migrate();
//}
app.Run();
