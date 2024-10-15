using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;


using CarCareHub.Services.Database;
using CarCareHub.Services.ProizvodiStateMachine;
using CarCareHub_;
using CarCareHub_.Errors;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using System.Text.Json;
using System.Text.Json.Serialization;




//////////////////////////////////////////////////////// Facebook SDK
//using Microsoft.AspNetCore.Authentication.Facebook;
//using Microsoft.AspNetCore.Authentication.Cookies;

//////////////////////////////////////////////////////// Facebook SDK









var builder = WebApplication.CreateBuilder(args);


//////////////////////////////////////////////////////// Facebook SDK
///
// Konfiguracija CORS-a
//builder.Services.AddCors(options =>
//{
//    options.AddDefaultPolicy(builder =>
//    {
//        builder.AllowAnyOrigin()
//               .AllowAnyMethod()
//               .AllowAnyHeader();
//    });
//});


//builder.Services.AddAuthentication(options =>
//{
//    options.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
//    options.DefaultChallengeScheme = FacebookDefaults.AuthenticationScheme;
//})
//.AddCookie() // Omogucuje koristenje cookie-based autentifikacije
//.AddFacebook(facebookOptions =>
//{
//    // Postavljanje AppId i AppSecret iz appsettings
//    facebookOptions.AppId = builder.Configuration["Authentication:Facebook:AppId"];
//    facebookOptions.AppSecret = builder.Configuration["Authentication:Facebook:AppSecret"];
//});
//builder.Services.AddControllersWithViews();

//////////////////////////////////////////////////////// Facebook SDK






// Add services to the container.
builder.Services.AddTransient<IProizvodiService, ProizvodiService>();

//builder.Services.AddTransient<IFirmaAutodijelovaService, FirmaAutodijelovaService>();
//builder.Services.AddTransient<IGradService, GradService>();
//builder.Services.AddTransient<  IService<CarCareHub.Model.Grad>, GradService>();
//builder.Services.AddTransient<IService<CarCareHub.Model.Zaposlenik, ZaposlenikSearchObject>, BaseService<CarCareHub.Model.Zaposlenik,
//    CarCareHub.Services.Database.Zaposlenik, ZaposlenikSearchObject>>();

//RADIbuilder.Services.AddTransient<ICRUDService<CarCareHub.Model.Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate>, ZaposlenikService>();
//builder.Services.AddTransient<ICRUDService<CarCareHub.Model.Grad, GradSearchObject, GradInsert, GradUpdate>, BaseCRUDService<CarCareHub.Model.Grad, CarCareHub.Services.Database.Grad, GradSearchObject, GradInsert, GradUpdate>>();
//builder.Services.AddTransient<ICRUDService<CarCareHub.Model.FirmaAutodijelova, FirmaAutodijelovaSearchObject, FirmaAutodijelovaInsert, FirmaAutodijelovaUpdate>, BaseCRUDService<CarCareHub.Model.FirmaAutodijelova, CarCareHub.Services.Database.FirmaAutodijelova, FirmaAutodijelovaSearchObject, FirmaAutodijelovaInsert, FirmaAutodijelovaUpdate>>();
//builder.Services.AddTransient<ICRUDService<CarCareHub.Model.Drzava, DrzavaSearchObject, DrzavaInsert, DrzavaUpdate>, BaseCRUDService<CarCareHub.Model.Drzava, CarCareHub.Services.Database.Drzava, DrzavaSearchObject, DrzavaInsert, DrzavaUpdate>>();
//builder.Services.AddTransient<ICRUDService<CarCareHub.Model.Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate>, BaseCRUDService<CarCareHub.Model.Zaposlenik, CarCareHub.Services.Database.Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate>>();
//builder.Services.AddTransient<ICRUDService<CarCareHub.Model.Kategorija, KategorijaSearchObject, KategorijaInsert, KategorijaUpdate>, BaseCRUDService<CarCareHub.Model.Kategorija, CarCareHub.Services.Database.Kategorija, KategorijaSearchObject, KategorijaInsert, KategorijaUpdate>>();
//builder.Services.AddTransient<ICRUDService<CarCareHub.Model.Proizvodjac, ProizvodjacSearchObject, ProizvodjacInsert, ProizvodjacUpdate>, BaseCRUDService<CarCareHub.Model.Proizvodjac, CarCareHub.Services.Database.Proizvodjac, ProizvodjacSearchObject, ProizvodjacInsert, ProizvodjacUpdate>>();
//builder.Services.AddTransient<ICRUDService<CarCareHub.Model.Uloge, UlogeSearchObject, UlogeInsert, UlogeUpdate>, BaseCRUDService<CarCareHub.Model.Uloge, CarCareHub.Services.Database.Uloge, UlogeSearchObject, UlogeInsert, UlogeUpdate>>();
//builder.Services.AddTransient<ICRUDService<CarCareHub.Model.Usluge, UslugeSearchObject, UslugeInsert, UslugeUpdate>, BaseCRUDService<CarCareHub.Model.Usluge, CarCareHub.Services.Database.Usluge, UslugeSearchObject, UslugeInsert, UslugeUpdate>>();
//builder.Services.AddTransient<ICRUDService<CarCareHub.Model.Vozilo, VoziloSearchObject, VoziloInsert, VoziloUpdate>, BaseCRUDService<CarCareHub.Model.Vozilo, CarCareHub.Services.Database.Vozilo, VoziloSearchObject, VoziloInsert, VoziloUpdate>>();
//builder.Services.AddTransient<ICRUDService<CarCareHub.Model.Autoservis, AutoservisSearchObject, AutoservisInsert, AutoservisUpdate>, BaseCRUDService<CarCareHub.Model.Autoservis, CarCareHub.Services.Database.Autoservis, AutoservisSearchObject, AutoservisInsert, AutoservisUpdate>>();
builder.Services.AddTransient<IDrzavaService, DrzavaService>();
builder.Services.AddTransient<IModelService, ModelService>();

builder.Services.AddTransient<IKategorijaService, KategorijaService>();
builder.Services.AddTransient<IUlogeService, UlogeService>();
builder.Services.AddTransient<IUslugeService, UslugeService>();
builder.Services.AddTransient<IGradService, GradService>();
builder.Services.AddTransient<IZaposlenikService, ZaposlenikService>();
builder.Services.AddTransient<IAutoservisService, AutoservisService>();
builder.Services.AddTransient<IFirmaAutodijelovaService, FirmaAutodijelovaService>();
builder.Services.AddTransient<IKlijentService, KlijentService>();
builder.Services.AddTransient<INarudzbaStavkaService, NarudzbaStavkaService>();
builder.Services.AddTransient<INarudzbaService, NarudzbaService>();
builder.Services.AddTransient<IPlacanjeAutoservisDijeloviService, PlacanjeAutoservisDijeloviService>();
builder.Services.AddTransient<IModelService, ModelService>();
builder.Services.AddTransient<IGodisteService, GodisteService>();
builder.Services.AddTransient<IVoziloService, VoziloService>();
builder.Services.AddTransient<IPorukaService, PorukaService>();
builder.Services.AddTransient<IChatKlijentZaposlenikService, ChatKlijentZaposlenikService>();
builder.Services.AddTransient<IAutoservisUslugeServices, AutoservisUslugeServices>();
builder.Services.AddTransient<IChatKlijentAutoservisService, ChatKlijentAutoservisService>();
builder.Services.AddTransient<IBPAutodijeloviAutoservisService, BPAutodijeloviAutoservisService>();


//-------------------------------------------------------------------

// Serializacija objekta s postavljenim opcijama

//-----------------------------------------------------------------------------------------------------------------------------------


// Ostali servisi
//builder.Services.AddTransient<IZaposlenikService, ZaposlenikService>();

builder.Services.AddTransient<BaseState>();
builder.Services.AddTransient<InitialProductState>();
builder.Services.AddTransient<DraftProductState>();
builder.Services.AddTransient<ActiveProductState>();


builder.Services.AddControllers(/* x => {  x.Filters.Add<ErrorFilter>(); }*/);
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("basicAuth", new Microsoft.OpenApi.Models.OpenApiSecurityScheme()
    {
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "basic"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference{Type = ReferenceType.SecurityScheme, Id = "basicAuth"}
            },
            new string[]{}
    } });

});






var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<CchV2AliContext>(options =>
options.UseSqlServer(connectionString));

builder.Services.AddAutoMapper(typeof(IGradService));
builder.Services.AddAutoMapper(typeof(IFirmaAutodijelovaService));
builder.Services.AddAutoMapper(typeof(IZaposlenikService));
builder.Services.AddAutoMapper(typeof(IKlijentService));

builder.Services.AddAuthentication("BasicAuthentication").AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

 
var app = builder.Build();

// Configure the HTTP request pipeline.


if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "My API V1");
        c.RoutePrefix = "swagger"; // Postavite rutu za Swagger UI
    });
    //}


    //////////////////////////////////////////////////////// Facebook SDK
    //app.UseCors();
    //app.UseStaticFiles();

    //app.UseRouting();
    //////////////////////////////////////////////////////// Facebook SDK


    app.UseHttpsRedirection();

app.UseAuthentication();

app.UseAuthorization();



app.MapControllers();


//using (var scope = app.Services.CreateScope())
//{
//    var dataContext = scope.ServiceProvider.GetRequiredService<CchV2AliContext>();

//    // dataContext.Database.EnsureCreated();
//    var conn = dataContext.Database.GetConnectionString();
//    dataContext.Database.Migrate();
//}
app.Run();
}
