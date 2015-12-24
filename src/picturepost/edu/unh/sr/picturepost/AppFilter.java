package edu.unh.sr.picturepost;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;

import edu.unh.sr.picturepost.DBPool;

public class AppFilter implements Filter {
   private FilterConfig filterConfig = null;

   public void init(FilterConfig filterConfig) 
      throws ServletException {
      this.filterConfig = filterConfig;
   }

   public void destroy() {
      this.filterConfig = null;
   }

	public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
      if (filterConfig == null) return;
      filterChain.doFilter(servletRequest, servletResponse);
      DBPool.returnDefaultConnection();
	}

}
