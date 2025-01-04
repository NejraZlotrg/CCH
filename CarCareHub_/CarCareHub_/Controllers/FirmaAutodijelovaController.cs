using Microsoft.AspNetCore.Mvc;
using CarCareHub.Services;
using CarCareHub.Services.Database;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using Microsoft.AspNetCore.Authorization;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/firmaAutodijelova")]
    [AllowAnonymous]

    public class FirmaAutodijelovaController : BaseCRUDController<CarCareHub.Model.FirmaAutodijelova, FirmaAutodijelovaSearchObject, FirmaAutodijelovaInsert, FirmaAutodijelovaUpdate>
    {


        public FirmaAutodijelovaController(ILogger<BaseController<CarCareHub.Model.FirmaAutodijelova, FirmaAutodijelovaSearchObject>> logger,
            IFirmaAutodijelovaService firmaAutodijelovaService) : base(logger, firmaAutodijelovaService)
        {
           
        }


        [HttpPost("login")]
        [AllowAnonymous]

        public async Task<CarCareHub.Model.FirmaAutodijelova> Login(string username, string password)
        {
            return await (_service as IFirmaAutodijelovaService).Login(username, password);

        }

        [HttpPost("get-id")]
        [AllowAnonymous]
        public IActionResult GetIdByUsernameAndPassword(string username, string password)
        {
            // Poziv metode servisa za dobivanje korisničkog ID-a.
            var id = (_service as IFirmaAutodijelovaService)?.GetIdByUsernameAndPassword(username, password);

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
