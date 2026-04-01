-- Consulta de Movimientos de Cuentas Sac x CHEQUES
-- Creado    : 29/12/2008 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac155('121020402','COB12091','18/12/2009')

drop procedure sp_sac155;
create procedure sp_sac155(a_cuenta char(12), a_comp char(15), a_fecha date) 
returning	char(12),		--cuenta 
			char(15), 		--comprobante 
			date,			--fecha
			char(10),		-- 	requisicion
			dec(15,2),		-- 	debito
			dec(15,2),		-- 	credito
			dec(15,2);		-- 	neto

define i_comprobante	char(15);
define i_cuenta			char(12);
define i_origen			char(12);
define d_requis			char(10);
define d_remesa			char(10);
define d_credito		dec(15,2);
define i_credito		dec(15,2);
define i_debito			dec(15,2);
define d_debito			dec(15,2);
define i_neto			dec(15,2);
define i_notrx			integer;
define i_fechatrx		date;


set isolation to dirty read;

create temp table tmp_asiento(
		cuenta		char(12),
		comprobante	char(15),
		fechatrx	date,
		notrx		integer,
		debito		dec(15,2)   default 0,
		credito		dec(15,2)   default 0,
		neto		dec(15,2)   default 0,
		origen		char(3),
		requis		char(10)
		) with no log; 	

--  set debug file to "sp_sac155.trc";	
--  trace on;

foreach
	select res_notrx,
		   res_origen,
		   res_debito,
		   res_credito
	  into i_notrx,
		   i_origen,
		   i_debito,
		   i_credito
      from cglresumen
	 where res_cuenta		= a_cuenta
	   and res_comprobante	= a_comp
	   and res_fechatrx		= a_fecha
	 order by res_comprobante,res_fechatrx,res_notrx,res_noregistro,res_origen

	if i_origen in ('CHE','PLA') then

		foreach
			select no_requis,
				   sum(debito),
				   sum(credito) 
			  into d_requis,
			  	   d_debito,
			  	   d_credito
			  from deivid:chqchcta
			 where sac_notrx = i_notrx
			   and cuenta = a_cuenta
			 group by no_requis
			 order by no_requis

			if d_debito is null then
				let d_debito = 0; 
			end if
			
			if d_credito is null then
				let d_credito = 0; 
			end if

			let i_neto = d_debito - d_credito ;

			insert into tmp_asiento (
				cuenta,
				comprobante,
				fechatrx,
				notrx,
				debito,
				credito,
				neto,
				origen,
				requis )
			values (
				a_cuenta,
				a_comp,
				a_fecha,
				i_notrx,
				d_debito,
				d_credito,
				i_neto,
				i_origen,
				d_requis
				);
		end foreach;

	end if   
end foreach;

foreach	
  select requis,
		 sum(debito),
		 sum(credito),
		 sum(neto)
	into d_requis,
		 d_debito,
	     d_credito,
		 i_neto
    from tmp_asiento
	where cuenta      = a_cuenta
	and   comprobante = a_comp
	and   fechatrx    = a_fecha
	group by requis
	order by requis

  return a_cuenta,
		 a_comp,
		 a_fecha,
		 d_requis,
		 d_debito,
		 d_credito,
		 i_neto		   
    	 with resume;

end foreach;


drop table tmp_asiento;
end procedure					 