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

    }
}
