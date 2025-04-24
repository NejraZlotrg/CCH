using Microsoft.AspNetCore.Mvc;
using CarCareHub.Services;
using CarCareHub.Services.Database;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using static CarCareHub.Services.NarudzbaStavkaService;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/narudzbaStavka")]
    public class NarudzbaStavkaController : BaseCRUDController<CarCareHub.Model.NarudzbaStavka, NarudzbaStavkaSearchObject, NarudzbaStavkaInsert, NarudzbaStavkaUpdate>
    {
        public NarudzbaStavkaController(ILogger<BaseController<CarCareHub.Model.NarudzbaStavka, NarudzbaStavkaSearchObject>> logger,
            INarudzbaStavkaService narudzbaStavkaService) : base(logger, narudzbaStavkaService)
        {
        }
        [HttpGet("{narudzbaId}/ByNarudzbaId")]
        public async Task<ActionResult<SearchResult<CarCareHub.Model.NarudzbaStavka>>> GetByNarudzbaId(int narudzbaId)
        {
            try
            {
                var service = (INarudzbaStavkaService)_service;
                var stavke = await service.GetByNarudzbaID(narudzbaId);
                return Ok(stavke);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = $"Greška pri dohvatu stavki narudžbe: {ex.Message}" });
            }
        }
    }
}
