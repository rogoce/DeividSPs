------------------------------------------------
--      EMICARTASAL2          --
---  Henry Giron - 13/12/2011 --
------------------------------------------------
drop procedure sp_pro4944a;
create procedure sp_pro4944a(a_tipo smallint default 0)
returning smallint ;

begin
  define _anio		smallint;

if a_tipo = 0 then
	foreach
		select distinct emicartasal.periodo[1,4]  
		  into _anio
		  from emicartasal
	    return _anio with resume;
	end foreach
else
	foreach
		select distinct emicartasal2.periodo[1,4]
		  into _anio
		  from emicartasal2  
		  return _anio with resume;
	end foreach
end if
end
end procedure	