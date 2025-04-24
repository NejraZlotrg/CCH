using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/vozilo")]
    public class VoziloController : BaseCRUDController<CarCareHub.Model.Vozilo, VoziloSearchObject, VoziloInsert, VoziloUpdate>
    {
        public VoziloController(ILogger<BaseController<CarCareHub.Model.Vozilo, VoziloSearchObject>> logger,
            IVoziloService service) : base(logger, service)
        {
        }
    }
}
