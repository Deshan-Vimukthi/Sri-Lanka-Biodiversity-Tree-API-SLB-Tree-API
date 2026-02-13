package org.api.slbtreeapi._config.redis_config;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    @Cacheable(value = "users", key = "#id")
    public String getUser(String id) {
        try { Thread.sleep(2000); } catch (Exception e) {}
        return "User-" + id;
    }
}

