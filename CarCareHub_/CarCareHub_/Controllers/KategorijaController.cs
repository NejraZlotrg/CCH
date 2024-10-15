using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Authorization;


namespace CarCareHub_.Controllers
{
    [ApiController]
    //[AllowAnonymous]
    [Route("api/kategorija")]
    public class KategorijaController : BaseCRUDController<Kategorija, KategorijaSearchObject, KategorijaInsert, KategorijaUpdate>
    {
        public KategorijaController(ILogger<BaseController<CarCareHub.Model.Kategorija, KategorijaSearchObject>> logger,
              IKategorijaService kategorijaService) : base(logger, kategorijaService)
        {
        }
    }
}