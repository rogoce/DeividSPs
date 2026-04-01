-- Procedimiento para consultar si son pólizas SODA
-- Creado    : 05/08/2009 - Autor: Roberto Silvera
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro861;
create procedure "informix".sp_pro861(a_poliza char(10))
	   returning smallint;

define v_cod_pro		char(5);
define v_cod_formapag	char(3);
define v_subramo		char(3);
define v_ramo			char(3);
define v_primab			dec(16,2);
define v_bandera		smallint;


let v_bandera = 0;
foreach
	select e.prima_bruta,   
		   e.cod_ramo,   
		   e.cod_subramo,   
		   u.cod_producto,
		   e.cod_formapag
	  into v_primab,
		   v_ramo,
		   v_subramo,
		   v_cod_pro,
		   v_cod_formapag
	  from emipomae e, emipouni u
	 where u.no_poliza = e.no_poliza
	   and e.no_poliza = a_poliza

	--VERIFICA QUE LAS UNIDADES NO TENGA EL PRODUCTO SODA
	if v_cod_pro = "00690","00723","00787","00940","00999","01056","01175") then
		let v_bandera = 1;
		exit foreach;
	end if		
	
	--PAGOS ELECTRONICOS
	if v_cod_formapag in ("003","005") then 
		
		--PARTICULARES
		if v_subramo = "001" and v_primab in(129.32,137.01,170.93,159.55) then
			let v_bandera = 1;
			exit foreach;
		end if

		--COMERCIALES
		if v_subramo = "002" and v_primab in (165,192.49,275,198.22) then
			let v_bandera = 1;
			exit foreach;	
		end if

	--PAGOS NO ELECTRONICOS
	else 		
		--PARTICULARES
		if v_subramo = "001" and v_primab in(122.85,130.15,162.38,151.55) then
			let v_bandera = 1;
			exit foreach;	
		end iF

		--COMERCIALES
		if v_subramo = "002" and v_primab in(150,175,250,180.20 ) then
			let v_bandera = 1;
			exit foreach;	
		end if
	end if
end foreach

return v_bandera;
end procedure;