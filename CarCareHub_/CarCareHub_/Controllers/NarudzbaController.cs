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
                return Ok(narudzba);
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
                var narudzbe = await _narudzbaService.GetByLogeedUser_(id);
                if (narudzbe == null || !narudzbe.Any())
                {
                    return NotFound(new { message = "Nema narudžbi za ovog korisnika." });
                }
                return Ok(narudzbe);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
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
            return nar; 
        }
        [HttpGet("IzvjestajzaAutoservis")]
        public async Task<List<AutoservisIzvjestaj>> GetAutoservisIzvjestaj()
        {
            var nar = await _narudzbaService.GetAutoservisIzvjestaj();
            return nar; 
        }
        [HttpGet("IzvjestajzaKlijenta")]
        public async Task<List<KlijentIzvjestaj>> GetNarudzbeZaSveKlijente()
        {
            var nar = await _narudzbaService.GetNarudzbeZaSveKlijente();
            return nar;
        }
        [HttpGet("IzvjestajzaZaposlenike")]
        public async Task<List<ZaposlenikIzvjestaj>> GetNarudzbeZaSveZaposlenike()
        {
            var nar = await _narudzbaService.GetNarudzbeZaSveZaposlenike();
            return nar; 
        }
    }
}
