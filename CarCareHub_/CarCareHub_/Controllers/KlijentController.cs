using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [AllowAnonymous]
    [Route("api/klijent")]

    //[Authorize]
    public class KlijentiController : BaseCRUDController<CarCareHub.Model.Klijent, KlijentSearchObject, KlijentInsert, KlijentUpdate>
    {
        public KlijentiController(ILogger<BaseController<CarCareHub.Model.Klijent, KlijentSearchObject>> logger,
              IKlijentService Service) : base(logger, Service)
        {
        }
        [HttpPost("login")]
        [AllowAnonymous]

        public async Task<CarCareHub.Model.Klijent> Login(string username, string password)
        {
            return await (_service as IKlijentService).Login(username, password);

        }

        [HttpPost("get-id")]
        [AllowAnonymous]
        public IActionResult GetIdByUsernameAndPassword(string username, string password)
        {
            // Poziv metode servisa za dobivanje korisničkog ID-a.
            var id = (_service as IKlijentService)?.GetIdByUsernameAndPassword(username, password);

            // Ako korisnik nije pronađen, vraća 404 status sa porukom.
            if (id == null)
            {
                return NotFound("Invalid username or password");
            }

            // Ako je korisnik pronađen, vraća ID u formatu JSON.
            return Ok(new { Id = id });
        }


    }
}