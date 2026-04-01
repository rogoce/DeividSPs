------------------------------------------------
--      EMICARTASAL2          --
---  Henry Giron - 13/12/2011 --
------------------------------------------------
drop procedure sp_pro4944;
create procedure sp_pro4944(a_tipo smallint default 0,a_anio char(250))
returning char(7);

begin
  define _periodo	char(7);
  define _tipo		char(1);
  define _cnt_anio	smallint;

if a_anio <> '*' then
	let _tipo = sp_sis04(a_anio); -- Separa los valores del String			
	
	--Temporal mientras se hace exe para aplicar el filtro desde PowerBuilder	Roman Gordon	11/12/2012
	select count(*)
	  into _cnt_anio
	  from tmp_codigos
	 where codigo = '2013';
	 
	if _cnt_anio > 0 then
		let a_tipo = 1;
	end if
	-----------------------------------------***********************************************************************-----------------------------------------
end if

if a_tipo = 0 then
	foreach
		select distinct emicartasal.periodo  
		  into _periodo
		  from emicartasal
		 group by emicartasal.periodo 
		 order by emicartasal.periodo desc
		
		if a_anio <> '*' then
			if _periodo[1,4] not in (select codigo from tmp_codigos) then
				continue foreach;
			end if
		end if		
		 
	    return _periodo with resume;
	end foreach
else
	foreach
		select distinct emicartasal2.periodo  
		  into _periodo
		  from emicartasal2  
		 group by emicartasal2.periodo 
		 order by emicartasal2.periodo desc
		 
		if a_anio <> '*' then
			if _periodo[1,4] not in (select codigo from tmp_codigos) then
				continue foreach;
			end if
		end if
		
		return _periodo with resume;
	end foreach
end if
if a_anio <> '*' then
	drop table tmp_codigos;
end if

end
end procedure  	