using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Authorization;


namespace CarCareHub_.Controllers
{
    [ApiController]
    [AllowAnonymous]
    [Route("api/[controller]")]
    public class KategorijaController : BaseCRUDController<Kategorija, KategorijaSearchObject, KategorijaInsert, KategorijaUpdate>
    {
        public KategorijaController(ILogger<BaseController<CarCareHub.Model.Kategorija, KategorijaSearchObject>> logger,
             ICRUDService<Kategorija, KategorijaSearchObject, KategorijaInsert, KategorijaUpdate> service) : base(logger, service)
        {
        }
    }
}