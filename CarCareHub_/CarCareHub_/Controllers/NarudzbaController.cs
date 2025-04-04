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

        [HttpPut("{narudzbaId}/potvrdi")]
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

        [HttpGet("{id}/GetPoUseru")]
        public async Task<IActionResult> GetByLoggedUser(int id)
        {
            try
            {
                // Poziv servisa da dobije narudžbe na osnovu korisničke uloge i id-a
                var narudzbe = await _narudzbaService.GetByLogeedUser_(id);

                // Ako nije pronađeno ništa, vraćamo status 404 (Not Found)
                if (narudzbe == null || !narudzbe.Any())
                {
                    return NotFound(new { message = "Nema narudžbi za ovog korisnika." });
                }

                // Vraćamo status 200 (OK) sa listom narudžbi
                return Ok(narudzbe);
            }
            catch (Exception ex)
            {
                // Ako je došlo do greške, vraćamo status 400 (Bad Request) sa porukom greške
                return BadRequest(new { message = ex.Message });
            }
        }


        //[HttpPost("DodajStavkuUKosaricu")]

        //public async Task<Narudzba> DodajStavkuUKosaricu(int proizvodId, int kolicina)
        //{
        //    try
        //    {
        //        // Pozivanje servisa za dodavanje stavke u košaricu
        //        var narudzba = await _narudzbaService.DodajStavkuUKosaricu(proizvodId, kolicina);

        //        // Ako je uspješno, vraćamo ažuriranu narudžbu
        //        return narudzba;
        //    }
        //    catch (Exception ex)
        //    {

        //        var narudzba = new Narudzba();
        //        return null;
        //    }
        //}
        [HttpGet("izvjestaj")]
        public async Task<ActionResult<List<IzvjestajNarudzbi>>> GenerisiIzvjestaj([FromQuery] DateTime? odDatuma, [FromQuery] DateTime? doDatuma, [FromQuery] int? kupacId, [FromQuery] int? zaposlenikId, [FromQuery] int? autoservisId)
        {
            var izvjestaj = await _narudzbaService.GetIzvjestajNarudzbi(odDatuma, doDatuma, kupacId, zaposlenikId, autoservisId);
            return Ok(izvjestaj);
        }


        [HttpGet("fm")]
        public async Task<List<CarCareHub.Model.Narudzba>> GetNarudzbeZaFirmu(int id)
        {
            var nar = await _narudzbaService.GetNarudzbeZaFirmu(id);
            return nar; // Directly return the list
        }

        [HttpGet("IzvjestajzaAutoservis")]

        public async Task<List<AutoservisIzvjestaj>> GetAutoservisIzvjestaj()
        {
            var nar = await _narudzbaService.GetAutoservisIzvjestaj();
            return nar; // Directly return the list
        }


        [HttpGet("IzvjestajzaKlijenta")]

        public async Task<List<KlijentIzvjestaj>> GetNarudzbeZaSveKlijente()
        {
            var nar = await _narudzbaService.GetNarudzbeZaSveKlijente();
            return nar; // Directly return the list
        }
        [HttpGet("IzvjestajzaZaposlenike")]

        public async Task<List<ZaposlenikIzvjestaj>> GetNarudzbeZaSveZaposlenike()

        {
            var nar = await _narudzbaService.GetNarudzbeZaSveZaposlenike();
            return nar; // Directly return the list
        }
    }
}
