using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/placanjeAutoservisDijelovi")]
    public class PlacanjeAutoservisDijeloviController : BaseCRUDController<PlacanjeAutoservisDijelovi, PlacanjeAutoservisDijeloviSearchObject, PlacanjeAutoservisDijeloviInsert, PlacanjeAutoservisDijeloviUpdate>
    {
        public PlacanjeAutoservisDijeloviController(ILogger<BaseController<PlacanjeAutoservisDijelovi, PlacanjeAutoservisDijeloviSearchObject>> logger,
             IPlacanjeAutoservisDijeloviService Service) : base(logger, Service)
        {
        }
    }
}
