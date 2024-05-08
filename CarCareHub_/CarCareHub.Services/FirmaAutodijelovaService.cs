using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using CarCareHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace CarCareHub.Services
{


    public class FirmaAutodijelovaService : BaseCRUDService<Model.FirmaAutodijelova, Database.FirmaAutodijelova, FirmaAutodijelovaSearchObject, FirmaAutodijelovaInsert, FirmaAutodijelovaUpdate>, IFirmaAutodijelovaService
    {
        CarCareHub.Services.Database.CchV2AliContext _dbContext;
        IMapper _mapper { get; set; }

        public FirmaAutodijelovaService(CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }
        public override Task<Model.FirmaAutodijelova> Insert(Model.FirmaAutodijelovaInsert insert)
        {
            return base.Insert(insert);
        }

        public override async Task<Model.FirmaAutodijelova> Update(int id, Model.FirmaAutodijelovaUpdate update)
        {
            return await base.Update(id, update);
        }

        public override async Task<Model.FirmaAutodijelova> Delete(int id)
        {
            return await base.Delete(id);
        }

        //public override async Task<Model.FirmaAutodijelova> GetByID(int id)
        //{
        //    var temp = await _dbContext.FirmaAutodijelovas
        //        .Include(f => f.BPAutodijeloviAutoservis)
        //            .ThenInclude(bp => bp.Autoservis.Naziv)
        //        .FirstOrDefaultAsync(f => f.FirmaAutodijelovaID == id);

        //    // Ovdje ograničavamo broj podataka u kolekciji na primjer 10
        //    if (temp.BPAutodijeloviAutoservis != null)
        //    {
        //        temp.BPAutodijeloviAutoservis = temp.BPAutodijeloviAutoservis.Take(10).ToList();
        //    }

        //    return _mapper.Map<Model.FirmaAutodijelova>(temp);
        //}



        public override IQueryable<Database.FirmaAutodijelova> AddInclude(IQueryable<Database.FirmaAutodijelova> query, FirmaAutodijelovaSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            if (search?.IsAllncluded == true)
            {
                query = query.Include(z => z.Grad);
                query = query.Include(z => z.Grad.Drzava);
                query = query.Include(z => z.Uloga);
               
                query=query.AsQueryable();

            }
            return base.AddInclude(query, search);
        }
       
        //protected override IQueryable<Database.FirmaAutodijelova> GetCollection(IQueryable<Database.FirmaAutodijelova> query, FirmaAutodijelovaSearchObject? search)
        //{
        //    // Ako želite uključiti kolekciju 'BPAutodijeloviAutoservis' unutar 'FirmaAutodijelova'

        //    query = query.Include(firma => firma.BPAutodijeloviAutoservis).Where(k=>k.FirmaAutodijelovaID==2);

        //    return base.GetCollection(query, search);
        //}
        //public static string GenerateSalt()
        //{
        //    RNGCryptoServiceProvider provider = new RNGCryptoServiceProvider();
        //    var byteArray = new byte[16];
        //   provider.GetBytes(byteArray);


        //    return Convert.ToBase64String(byteArray);
        //}
        //public static string GenerateHash(string salt, string password)
        //{
        //    byte[] src = Convert.FromBase64String(salt);
        //    byte[] bytes = Encoding.Unicode.GetBytes(password);
        //    byte[] dst = new byte[src.Length + bytes.Length];

        //    System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
        //    System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

        //    HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
        //    byte[] inArray = algorithm.ComputeHash(dst);
        //    return Convert.ToBase64String(inArray);
        //}


    }
}


       
       
    

