﻿using Chillgo.Repository.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Chillgo.Repository.Interfaces
{
    public interface IPackageTransactionRepository
    {
        Task AddTransactionAsync(PackageTransaction transaction);
        Task<PackageTransaction> GetTransactionByIdAsync(Guid transactionId);
        Task<List<PackageTransaction>> GetAllTransactionsAsync();
    }
}
