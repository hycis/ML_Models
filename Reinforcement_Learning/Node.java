
public class Node 
{	
	/** The utility at each cell */
	private double utility;
	
	/** The policy at each cell */
	private int dir;
	
	public Node()
	{
		this.utility = 0;
		this.dir = 0;
	}
	
	public Node(double util)
	{
		this.utility = util;
	}
	
	public Node(double util, int dir)
	{
		this.utility = util;
		this.dir = dir;
	}
	
	public double getUtil()
	{
		return this.utility;
	}
	
	public void setUtil(double utility) 
	{
		this.utility = utility;
	}
	
	public int getDir()
	{
		return this.dir;
	}
	
	public void setDir(int dir)
	{
		this.dir = dir;
	}
}
