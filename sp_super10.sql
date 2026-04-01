   --Procedimiento de verificacion
   --  Armando Moreno M. 21/04/2017
   
   DROP procedure sp_super10;
   CREATE procedure sp_super10()
   RETURNING char(20);

   DEFINE _no_poliza     CHAR(10);
   DEFINE _poliza        CHAR(20);
   DEFINE _cod_agente,_no_factura	 CHAR(10);
   define _cnt,_renglon           smallint;
   define _n_agente      char(50);
   define _tipo_agente   char(1);
   define _no_endoso     char(10);
   define _no_poliza2    char(10);
   define _monto         dec(16,2);
   
SET ISOLATION TO DIRTY READ;
let _poliza = "";
{foreach
	select no_factura,
	       poliza
	  into _no_factura,
           _poliza	  
	  from sal_comis
	let _no_poliza = sp_sis21(_poliza);
	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

		 exit foreach;
    end foreach
	
	select tipo_agente
	  into _tipo_agente
	  from agtagent
	 where cod_agente = _cod_agente;

    if _tipo_agente = 'O' then
		update emipoagt
		   set porc_comis_agt = 0.00
		 where no_poliza = _no_poliza
           and cod_agente = _cod_agente;		  
	end if
	select no_endoso,no_poliza
	  into _no_endoso,_no_poliza2
	  from endedmae
	 where no_factura = _no_factura;
	
	update endmoage
	   set porc_comis_agt = 0.00
	 where no_poliza = _no_poliza2
       and no_endoso = _no_endoso;	 
	 
end foreach}
{let _renglon = 0;
foreach
	select no_documento
	  into _poliza
	  from aa
	  
	  let _no_poliza = sp_sis21(_poliza);

	  select no_factura
	    into _no_factura
		from emipomae
	   where no_poliza = _no_poliza;
	   let _renglon = _renglon + 1;
	   update aa
	      set no_poliza = _no_poliza,
		      no_endoso = '00000',
			  no_factura = _no_factura,
              renglon    = _renglon			  
		where no_documento = _poliza;
		
end foreach}
foreach
	select transaccion,monto
	  into _no_endoso,_monto
	from rectrmae
	where transaccion in(select transaccion from chqchrec
	where no_requis = '756539')
	
	update chqchrec
	   set monto = _monto
	  where no_requis = '756539'
       and transaccion = _no_endoso;
	   
end foreach

return _poliza;
END PROCEDURE;