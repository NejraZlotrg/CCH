using CarCareHub.Model;
using CarCareHub.Services; // Zamijeniti sa stvarnim prostorom imena za servise
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text;
using System.Text.Encodings.Web;

namespace CarCareHub_
{
    public class BasicAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
    {
        private readonly IFirmaAutodijelovaService _firmaService;
        private readonly IAutoservisService _autoservisService;
        private readonly IZaposlenikService _korisniciService;
        private readonly IKlijentService _klijentService;

        public BasicAuthenticationHandler(
            IFirmaAutodijelovaService firmaService,
            IZaposlenikService korisniciService,
            IAutoservisService autoservisService,
            IKlijentService klijentService,
            IOptionsMonitor<AuthenticationSchemeOptions> options,
            ILoggerFactory logger,
            UrlEncoder encoder,
            ISystemClock clock) : base(options, logger, encoder, clock)
        {
            _firmaService = firmaService;
            _korisniciService = korisniciService;
            _autoservisService = autoservisService;
            _klijentService = klijentService;
        }

        protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
        {
            if (!Request.Headers.ContainsKey("Authorization"))
            {
                return AuthenticateResult.Fail("Missing Authorization Header");
            }

            try
            {
                var authHeader = AuthenticationHeaderValue.Parse(Request.Headers["Authorization"]);
                var credentialsBytes = Convert.FromBase64String(authHeader.Parameter);
                var credentials = Encoding.UTF8.GetString(credentialsBytes).Split(':');

                if (credentials.Length != 2)
                {
                    return AuthenticateResult.Fail("Invalid Authorization Header Format");
                }

                var username = credentials[0];
                var password = credentials[1];

                // Provjera za svakog korisnika (firma, zaposleni, autoservis, klijent)
                var userFirma = await _firmaService.Login(username, password);
                var userKorisnik = await _korisniciService.Login(username, password);
                var userAutoservis = await _autoservisService.Login(username, password);
                var userKlijent = await _klijentService.Login(username, password);

                object user = null;
                string userId = null;

                // Dodavanje korisničkog ID-a temeljem vrste korisnika
                if (userFirma != null)
                {
                    user = userFirma;
                    userId = userFirma.FirmaAutodijelovaID.ToString();
                }
                else if (userKorisnik != null)
                {
                    user = userKorisnik;
                    userId = userKorisnik.ZaposlenikId.ToString();
                }
                else if (userAutoservis != null)
                {
                    user = userAutoservis;
                    userId = userAutoservis.AutoservisId.ToString();
                }
                else if (userKlijent != null)
                {
                    user = userKlijent;
                    userId = userKlijent.KlijentId.ToString();
                }

                if (user == null)
                {
                    return AuthenticateResult.Fail("Invalid Username or Password");
                }

                // Kreiranje claimova
                var claims = new List<Claim>
        {
            new Claim(ClaimTypes.Name, username),
            new Claim(ClaimTypes.NameIdentifier, userId), // Ovo dodajete ID kao Claim
        };

                // Dodavanje uloge korisniku
                if (user is FirmaAutodijelova)
                {
                    claims.Add(new Claim(ClaimTypes.Role, "FirmaAutodijelova"));
                }
                else if (user is Zaposlenik)
                {
                    claims.Add(new Claim(ClaimTypes.Role, "Zaposlenik"));
                }
                else if (user is Autoservis)
                {
                    claims.Add(new Claim(ClaimTypes.Role, "Autoservis"));
                }
                else if (user is Klijent)
                {
                    claims.Add(new Claim(ClaimTypes.Role, "Klijent"));
                }

                // Kreiranje identiteta i autentifikacijskog ticketa
                var identity = new ClaimsIdentity(claims, Scheme.Name);
                var principal = new ClaimsPrincipal(identity);
                var ticket = new AuthenticationTicket(principal, Scheme.Name);

                return AuthenticateResult.Success(ticket);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, "Error in Basic Authentication");
                return AuthenticateResult.Fail("Invalid Authorization Header");
            }
        }

    }
}
