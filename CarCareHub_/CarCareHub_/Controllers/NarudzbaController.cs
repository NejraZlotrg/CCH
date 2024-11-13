using Microsoft.AspNetCore.Mvc;
using CarCareHub.Services;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/narudzba")]
    public class NarudzbaController : BaseCRUDController<CarCareHub.Model.Narudzba, NarudzbaSearchObject, NarudzbaInsert, NarudzbaUpdate>
    {
        private readonly INarudzbaService _narudzbaService;

        public NarudzbaController(ILogger<BaseController<CarCareHub.Model.Narudzba, NarudzbaSearchObject>> logger,
            INarudzbaService narudzbaService) : base(logger, narudzbaService)
        {
            _narudzbaService = narudzbaService;
        }

        [HttpPost("{narudzbaId}/potvrdi")]
        public async Task<IActionResult> PotvrdiNarudzbu(int narudzbaId)
        {
            try
            {
                var narudzba = await _narudzbaService.PotvrdiNarudzbu(narudzbaId);
                return Ok(narudzba); // Vraća potvrđenu narudžbu
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("DodajStavkuUKosaricu")]

        public async Task<Narudzba> DodajStavkuUKosaricu(int proizvodId, int kolicina)
        {
            try
            {
                // Pozivanje servisa za dodavanje stavke u košaricu
                var narudzba = await _narudzbaService.DodajStavkuUKosaricu(proizvodId, kolicina);

                // Ako je uspješno, vraćamo ažuriranu narudžbu
                return narudzba;
            }
            catch (Exception ex)
            {

                var narudzba = new Narudzba();
                return null;
            }
        }

    }
}
