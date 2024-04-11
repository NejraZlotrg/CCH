using Microsoft.AspNetCore.Mvc;
using CarCareHub.Services;
using CarCareHub.Services.Database;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NarudzbaController : BaseCRUDController<CarCareHub.Model.Narudzba, NarudzbaSearchObject, NarudzbaInsert, NarudzbaUpdate>
    {


        public NarudzbaController(ILogger<BaseController<CarCareHub.Model.Narudzba, NarudzbaSearchObject>> logger,
            INarudzbaService narudzbaService) : base(logger, narudzbaService)
        {
           
        }
     
    }
}
