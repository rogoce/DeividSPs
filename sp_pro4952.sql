------------------------------------------------
--      EMICARTASAL2          --
--         CONTRATO DE REASEGURO              --
---  Henry Giron - 10/12/2011 --
------------------------------------------------
drop procedure sp_pro4952;
create procedure sp_pro4952(a_periodo char(7),
							a_tipo smallint default 1,
							a_imp1 smallint default 0,
							a_imp2 smallint default 0,
							a_envi1 smallint default 0,
							a_envi2 smallint default 0,
							a_envi3 smallint default 0,
							a_envi4 smallint default 0
						   )
returning	char(20);
																																												  
--integer li_imp1, li_imp2, li_envi1, li_envi2, li_envi3, li_envi4																												  
--string ls_periodo,ls_poliza
begin

define _nombre_zona		varchar(50);
define _nombre_cliente	char(100);
define _deducible_txt	char(100);
define _name_cliclien	char(100);
define _nombre_plan     char(100);
define _direccion		varchar(50);
define _direccion2		varchar(50);
define _nombre_agente	char(50);
define _no_documento	char(20);
define _deducible_din	char(18);
define _telefono1		char(10);
define _telefono2		char(10);
define _no_poliza		char(10);
define _celular      	char(10);
define _periodo			char(7);
define _cod_producto	char(5);
define _cod_agente		char(5);
define _cod_vendedor	char(3);
define _cod_formapag	char(3);
define _cod_subramo		char(3);
define _cod_perpago		char(3);
define _deducible_int	dec(16,2);
define _deducible		dec(16,2);
define _co_pago			dec(16,2);
define _prima			dec(16,2);
define _fecha_aniv		date;
define _subramo         char(20);

	set debug file to "sp_pro4939.trc";
	trace on;

If a_tipo = 1 then
	let _subramo = "'007','009','016'";
Else
	let _subramo = "'008','018'";
End If

If a_tipo = 1 then
	foreach
	  select emicartasal2.no_documento
		into _no_documento    
		from emicartasal2   
	   where emicartasal2.periodo		= a_periodo and  
			 (emicartasal2.impreso		= a_imp1 or  
			 emicartasal2.impreso		= a_imp2) and  
			 emicartasal2.enviado_a		in (a_envi1,a_envi2,a_envi3,a_envi4) and  
			 emicartasal2.cod_subramo in ('007','009','016')   
	order by emicartasal2.nombre_agente	asc,   
			 emicartasal2.no_documento	asc   	 
	return _no_documento with resume;


	end foreach
else
	foreach
	  select emicartasal2.no_documento
		into _no_documento    
		from emicartasal2   
	   where emicartasal2.periodo		= a_periodo and  
			 (emicartasal2.impreso		= a_imp1 or  
			 emicartasal2.impreso		= a_imp2) and  
			 emicartasal2.enviado_a		in (a_envi1,a_envi2,a_envi3,a_envi4) and  
			 emicartasal2.cod_subramo in ('008','018')   
	order by emicartasal2.nombre_agente	asc,   
			 emicartasal2.no_documento	asc   	 
	end foreach

end if



end

end procedure  

 
		