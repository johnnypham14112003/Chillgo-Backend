﻿using Chillgo.Repository.Models;

namespace Chillgo.Repository.Interfaces
{
    public interface IImageRepository : IGenericRepository<Image>
    {
        Task<Image?> GetImageAsync(string fileName, byte typeReference);
    }
}