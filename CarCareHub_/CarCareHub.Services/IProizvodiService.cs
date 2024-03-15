using CarCareHub.Model;
using CarCareHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{

    public interface IProizvodiService : ICRUDService<Model.Proizvod, CarCareHub.Model.SearchObjects.ProizvodiSearchObject, ProizvodiInsert, ProizvodiUpdate>
    {
       Task<Model.Proizvod> Activate(int id);
        Task<Model.Proizvod> Hide(int id);
        Task<List<string>> AllowedActions(int id);
    }
}