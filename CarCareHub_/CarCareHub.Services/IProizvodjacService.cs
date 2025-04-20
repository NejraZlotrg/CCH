using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public interface IProizvodjacService : ICRUDService<Model.Proizvodjac, ProizvodjacSearchObject, ProizvodjacInsert, ProizvodjacUpdate>
    {
        Task AddInitialProizvodjacAsync();
    }
}
