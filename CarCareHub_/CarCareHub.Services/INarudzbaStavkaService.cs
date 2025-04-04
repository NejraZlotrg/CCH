using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using static CarCareHub.Services.NarudzbaStavkaService;

namespace CarCareHub.Services
{
    public interface INarudzbaStavkaService : ICRUDService<Model.NarudzbaStavka, NarudzbaStavkaSearchObject, NarudzbaStavkaInsert, NarudzbaStavkaUpdate>
    {
   

    }
}