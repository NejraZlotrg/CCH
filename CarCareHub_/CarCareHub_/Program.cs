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
using CarCareHub_.Hubs;
using CarCareHub.Model.Configurations;

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
builder.Services.AddTransient<IBPAutodijeloviAutoservisService, BPAutodijeloviAutoservisService>();
builder.Services.AddTransient<IProizvodjacService, ProizvodjacService>();
builder.Services.AddTransient<IKorpaService, KorpaService>();
builder.Services.AddScoped<IChatAutoservisKlijentService, CarCareHub.Services.ChatAutoservisKlijentService>();
builder.Services.AddScoped<IRecommenderService, RecommenderService>();
builder.Services.AddTransient<IProizvodiService, ProizvodiService>();


builder.Services.AddTransient<BaseState>();
builder.Services.AddTransient<InitialProductState>();
builder.Services.AddTransient<DraftProductState>();
builder.Services.AddTransient<ActiveProductState>();
var stripeSettings = builder.Configuration.GetSection("Stripe");
builder.Services.Configure<StripeConfig>(stripeSettings);



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

builder.Services.AddHttpContextAccessor();



builder.Services.AddSignalR(options =>
{
    options.ClientTimeoutInterval = TimeSpan.FromSeconds(10); 
});


//// Dodaj CORS
//builder.Services.AddCors(options =>
//{
//    options.AddPolicy("AllowLocalhost", policy =>
//    {
//        policy.WithOrigins("", "http://localhost:7209") // Zamijeni sa svojim frontend URL-ovima
//              .AllowAnyHeader()
//              .AllowAnyMethod()
//              .AllowCredentials();
//    });
//});

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
    {
        builder.AllowAnyOrigin()
               .AllowAnyMethod()
               .AllowAnyHeader();
    });
});




var app = builder.Build();

app.UseCors("AllowAll");

app.MapControllers();
app.MapHub<ChatHub>("/chat-hub");


app.UseWebSockets();


await SeedUloge(app);

static async Task SeedUloge(WebApplication app)
{
    using (var scope = app.Services.CreateScope())
    {
        var ulogeService = scope.ServiceProvider.GetRequiredService<IUlogeService>();
        var gradService = scope.ServiceProvider.GetRequiredService<IGradService>();
        var drzavaService = scope.ServiceProvider.GetRequiredService<IDrzavaService>();

        var voziloService = scope.ServiceProvider.GetRequiredService<IVoziloService>();
        var klijentService = scope.ServiceProvider.GetRequiredService<IKlijentService>();
        var firmaService = scope.ServiceProvider.GetRequiredService<IFirmaAutodijelovaService>();
        var autoservisService = scope.ServiceProvider.GetRequiredService<IAutoservisService>();
        var zaposlenikService = scope.ServiceProvider.GetRequiredService<IZaposlenikService>();
        var godisteService = scope.ServiceProvider.GetRequiredService<IGodisteService>();
        var kategorijaService = scope.ServiceProvider.GetRequiredService<IKategorijaService>();
        var uslugeService = scope.ServiceProvider.GetRequiredService<IUslugeService>();
        var modelService = scope.ServiceProvider.GetRequiredService<IModelService>();
        var proizvodjacService = scope.ServiceProvider.GetRequiredService<IProizvodjacService>();
        var proizvodiService = scope.ServiceProvider.GetRequiredService<IProizvodiService>();
        var narudzbaService = scope.ServiceProvider.GetRequiredService<INarudzbaService>();
        var BPService = scope.ServiceProvider.GetRequiredService<IBPAutodijeloviAutoservisService>();



        await SeedUlogeAsync(ulogeService);
        await SeedDrzavaAsync(drzavaService);
        await SeedGradAsync(gradService);
        await SeedVoziloAsync(voziloService);
        await SeedAutoservisAsync(autoservisService);
        await SeedFirmaAsync(firmaService);
        await SeedKlijentAsync(klijentService);
        await SeedZaposlenikAsync(zaposlenikService);
        await SeedGodisteAsync(godisteService);
        await SeedKategorijaAsync(kategorijaService);
        await SeedModelAsync(modelService);
        await SeedUslugeAsync(uslugeService);
        await SeedProizvodjacAsync(proizvodjacService);
        await SeedProizvodiAsync(proizvodiService);
        await SeedNarudzbaAsync(narudzbaService);
        await SeedbpAsync(BPService);


    }
}
static async Task SeedUlogeAsync(IUlogeService ulogeService)
{
    await ulogeService.AddUlogeAsync();
}
static async Task SeedDrzavaAsync(IDrzavaService drzavaService)
{
    await drzavaService.AddDrzavaAsync();
}
static async Task SeedZaposlenikAsync(IZaposlenikService zaposlenikService)
{
    await zaposlenikService.AddZaposlenikAsync();
}
static async Task SeedGradAsync(IGradService gradService)
{
    await gradService.AddGradAsync();
}
static async Task SeedAutoservisAsync(IAutoservisService autoservisService)
{
    await autoservisService.AddAutoserviceAsync();
}
static async Task SeedVoziloAsync(IVoziloService voziloService)
{
    await voziloService.AddVoziloAsync();
}
static async Task SeedFirmaAsync(IFirmaAutodijelovaService firmaService)
{
    await firmaService.AddFirmaAsync();
}
static async Task SeedKlijentAsync(IKlijentService klijentService)
{
    await klijentService.AddKlijentAsync();
}
static async Task SeedGodisteAsync(IGodisteService godisteService)
{
    await godisteService.AddGodisteAsync();
}
static async Task SeedKategorijaAsync(IKategorijaService kategorijaService)
{
    await kategorijaService.AddKategorijaAsync();
}
static async Task SeedModelAsync(IModelService modelService)
{
    await modelService.AddModelAsync();
}
static async Task SeedProizvodjacAsync(IProizvodjacService proizvodjacService)
{
    await proizvodjacService.AddInitialProizvodjacAsync();
}
static async Task SeedUslugeAsync(IUslugeService uslugeService)
{
    await uslugeService.AddInitialUslugeAsync();
}
static async Task SeedProizvodiAsync(IProizvodiService proizvodiService)
{
    await proizvodiService.AddInitialProizvodiAsync();
}
static async Task SeedNarudzbaAsync(INarudzbaService narudzbaService)
{
    await narudzbaService.AddSampleNarudzbeAsync();
}
static async Task SeedbpAsync(IBPAutodijeloviAutoservisService BPService)
{
    await BPService.AddBPAutodijeloviAutoservisAsync();
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "My API V1");
        c.RoutePrefix = "swagger"; // Postavi rutu za Swagger UI
    });
    app.UseAuthentication();
    app.UseAuthorization();
    app.MapControllers();
    
    app.MapHub<ChatHub>("/chatHub");

    using (var scope = app.Services.CreateScope())
    {
        var dataContext = scope.ServiceProvider.GetRequiredService<CchV2AliContext>();
        var accommodationUnitService = scope.ServiceProvider.GetRequiredService<IRecommenderService>();
        try
        {
            await accommodationUnitService.TrainModelAsync();
        }
        catch (Exception)
        {
        }
    }
    app.Run();
}
