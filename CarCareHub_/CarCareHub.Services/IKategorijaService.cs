using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;

namespace CarCareHub.Services
{
    public interface IKategorijaService : ICRUDService<Kategorija, KategorijaSearchObject, KategorijaInsert, KategorijaUpdate>
    {
    }
}
