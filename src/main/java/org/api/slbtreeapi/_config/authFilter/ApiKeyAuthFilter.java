package org.api.slbtreeapi._config.authFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class ApiKeyAuthFilter extends OncePerRequestFilter {

    // Inject API key from properties
    /*@Value("${api.key}")*/
    private String apiKey = "k";

    // Header name
    private static final String HEADER_NAME = "X-API-KEY";

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String requestKey = request.getHeader(HEADER_NAME);

        if (requestKey == null || !requestKey.equals(apiKey)) {
            // API key missing or invalid
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Unauthorized: Invalid API Key");
            return;
        }

        // API key valid, continue processing
        filterChain.doFilter(request, response);
    }
}
