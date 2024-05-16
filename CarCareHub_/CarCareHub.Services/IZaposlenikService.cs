using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;

namespace CarCareHub.Services
{
    public interface IZaposlenikService : ICRUDService<Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate>
    {
        Task<CarCareHub.Model.Zaposlenik> GetByGrad(int id);
        public Task<Model.Zaposlenik> Login(string username, string password);

    }
}
