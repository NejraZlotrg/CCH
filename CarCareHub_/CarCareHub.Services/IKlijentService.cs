using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;

namespace CarCareHub.Services
{
    public interface IKlijentService : ICRUDService<Model.Klijent, KlijentSearchObject, KlijentInsert, KlijentUpdate>
    {
        public Task<Model.Klijent> Login(string username, string password);
        public int? GetIdByUsernameAndPassword(string username, string password);
        Task AddKlijentAsync();


    }
}