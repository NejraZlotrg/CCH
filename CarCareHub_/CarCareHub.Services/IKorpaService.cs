using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public interface IKorpaService : ICRUDService<Korpa, KorpaSearchObject, KorpaInsert, KorpaUpdate>
    {
        public Task<bool> DeleteProizvodIzKorpe(int? korpaId, int? proizvodId);
        public Task<bool> UpdateKolicina(int? korpaId, int? proizvodId, int novaKolicina);
        public Task<bool> OčistiKorpu(int? klijentId, int? zaposlenikId, int? autoservisId);

    }
}
