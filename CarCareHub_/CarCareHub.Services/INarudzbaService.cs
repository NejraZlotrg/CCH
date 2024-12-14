using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;

namespace CarCareHub.Services
{
    public interface INarudzbaService : ICRUDService<Model.Narudzba, NarudzbaSearchObject, NarudzbaInsert, NarudzbaUpdate>
    {
        public Task<Model.Narudzba> PotvrdiNarudzbu(int narudzbaId);

       // public  Task<Model.Narudzba> DodajStavkuUKosaricu(int proizvodId, int kolicina);



    }
}