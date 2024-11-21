using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public interface IFirmaAutodijelovaService : ICRUDService<Model.FirmaAutodijelova, FirmaAutodijelovaSearchObject,FirmaAutodijelovaInsert,FirmaAutodijelovaUpdate>
    {

        public Task<Model.FirmaAutodijelova> Login(string username, string password);

    }
}
