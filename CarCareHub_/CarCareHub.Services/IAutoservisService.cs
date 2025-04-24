using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;

namespace CarCareHub.Services
{
    public interface IAutoservisService : ICRUDService<Autoservis, AutoservisSearchObject, AutoservisInsert, AutoservisUpdate>
    {
        public Task<Model.Autoservis> Login(string username, string password);
        public int? GetIdByUsernameAndPassword(string username, string password);
        Task AddAutoserviceAsync();
    }
}