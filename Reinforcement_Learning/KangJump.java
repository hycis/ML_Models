/**
 * This program gives the best possible jumping route of a kangaroo from any starting 
 * cell to the food cell using policy iteration and value iteration algorithm. The jump 
 * j(t) at time t can be {-2, -1, 0, 1, 2}. Due to inertia, the absolute difference 
 * |j(t) - j(t-1)| <= 1. If the kangaroo hits the wall, he is bounced back with inertia 
 * direction reversed also. For more detailed explanation of the problem, visit part 2 
 * of http://www.cim.mcgill.ca/~jer/courses/ai/assignments/as2.html
 */

public class KangJump 
{	
	/** The reward for landing in an empty cell */
	private static double REWARD = 0;

	/** The value that is used to compute DELTA */
	private static final double EPSILON = 0.000000001;

	/** The multiplicative factor to the utility at the cell whenever the kangaroo 
	 * lands on the cell */
	private static final double DISCOUNT_FACTOR = 0.9;

	/** The delta use to compare with the maximum difference of two consecutive board */
	private static final double DELTA = EPSILON * (1 - DISCOUNT_FACTOR) / DISCOUNT_FACTOR;


	/** Position of hole 1 on the stretch of cells */
	private int hole1;

	/** Position of hole 2 on the stretch of cells */
	private int hole2;

	/** Position of food on the stretch of cells */
	private int food;

	/** Total number of cells in the game */
	private int numOfCells;

	/** The board representing utilities of all the possible states */
	private Node[][] board;

	public static void main(String[] args)
	{

		KangJump kj = new KangJump(2, 6, 4, 8);
		kj.hole1 = Integer.parseInt(args[0]);
		kj.hole2 = Integer.parseInt(args[1]);
		kj.food = Integer.parseInt(args[2]);
		kj.numOfCells = Integer.parseInt(args[3]);
		
		for (int i=0; i<3; i++)
		{
			if (REWARD == -0.5)
			{
				REWARD = -1;
			}
			
			else if (REWARD == -0.04)
			{
				REWARD = -0.5;
			}
			
			else if (REWARD == 0)
			{
				REWARD = -0.04;
			}
			kj.valueIteration();
			print("Utility of Value Iteration for r = " + REWARD, kj.board);
			printDir("Opt Policy of Value Iteration for r = " + REWARD, kj.board);
			System.out.println("The best path generated from value iteration");
			// printPath(startCell, prevJump, board)
			kj.printPath(0, 2, kj.board); // generate the best path starting from 0;
			System.out.println("-------------------------------------------------");

			kj.policyIteration();
			print("Utility of Policy Iteration for r =" + REWARD, kj.board);
			printDir("Opt Policy of Policy Iteration for r = " + REWARD, kj.board);
			System.out.println("The best path generated from policy iteration");
			// printPath(startCell, prevJump, board)
			kj.printPath(0, 2, kj.board); // generate the best path starting from 0;
			System.out.println("-------------------------------------------------");
		}
	}

	/** KangJump constructor
	 * @param hole1 location of first hole on the stretch of cells
	 * @param hole2 location of second hole on the stretch of cells
	 * @param food location of food on the stretch of cells
	 * @param numOfCells total number of cells
	 */
	public KangJump(int hole1, int hole2, int food, int numOfCells)
	{
		this.hole1 = hole1;
		this.hole2 = hole2;
		this.food = food;
		this.numOfCells = numOfCells;
	}

	/** Initialize a new Board
	 * Initialize all the starting states of the board, the food columns initialize to 1,
	 * the hole column initializes to -1, the rest initialize to 0.
	 */
	private void initializeBoard()
	{
		final int NUM_ROWS = 5;
		this.board = new Node[NUM_ROWS][this.numOfCells];
		for (int i=0; i<this.board.length; i++) 
		{
			for (int j=0; j<this.numOfCells; j++) 
			{
				if (j == this.hole1 || j == this.hole2) 
				{
					this.board[i][j] = new Node(-1);
				}
				else if (j == this.food) 
				{
					this.board[i][j] = new Node(1);
				}
				else 
				{
					this.board[i][j] = new Node(0);
				}
			}
		}		
	}

	/** Value Iteration Algorithm
	 * Use value iteration algorithm to generate a final board of converged utilities.
	 * The iteration stops when the maximum difference of two corresponding element in
	 * two consecutive iterated board is less than DELTA.
	 */
	private void valueIteration()
	{
		this.initializeBoard();

		double delta;
		int row = this.board.length;
		int col = this.board[0].length;
		Node[][] temp = duplicate(this.board);
		do 
		{
			delta = 0;
			for (int i=0; i<row; i++) 
			{
				for (int j=0; j<col; j++) 
				{
					if (!(j == hole1 || j == hole2 || j == food))
						this.updateUtil(i, j);
					double absDiff = Math.abs(board[i][j].getUtil() - temp[i][j].getUtil());
					if (absDiff > delta)
						delta = absDiff;
				}
			}
			temp = resetBoard(temp, this.board);
		} while (delta >= DELTA);
	}

	/** Policy Iteration Algorithm
	 * Use policy iteration algorithm to generate a final board of converged policy. 
	 * The iteration stops when the policy of two consecutive iterated board remain unchanged.
	 * The policy of the board is stored in Node.dir.
	 */
	private void policyIteration()
	{
		this.initializeBoard();
		boolean diffPolicy; // true if the policy for two consecutive board is the different
		int row = this.board.length;
		int col = this.board[0].length;
		Node[][] temp = duplicate(this.board);

		do 
		{
			diffPolicy = false;
			for (int i=0; i<row; i++) 
			{
				for (int j=0; j<col; j++) 
				{
					if ((j != this.hole1) && (j != this.hole2) && (j != this.food))
						this.updateUtil(i, j);
					if (this.board[i][j].getDir() != temp[i][j].getDir())
					{
						diffPolicy = true;
						break;
					}	
				}
				if (diffPolicy == true)
					break;
			}
			temp = resetBoard(temp, this.board);
		} while (diffPolicy);
	}

	/** Update Board Utility
	 * Update the utility and policy of the board each time it is called.
	 * @param r row of the board
	 * @param c column of the board
	 */
	private void updateUtil(int r, int c)
	{
		double max = -1000;
		for (int i=-1; i<=1; i++)
		{
			int prevJump = r - 2;
			int nextJump = prevJump + i;
			if (Math.abs(nextJump) > 2 )
				continue;
			int nextCol = c + nextJump;
			double temp = 0;
			if (nextCol < 0) 
			{
				temp = this.board[2 - nextJump][-nextCol-1].getUtil();
			}

			else if (nextCol >= this.numOfCells) 
			{
				temp = this.board[2 - nextJump][2*this.numOfCells - nextCol - 1].getUtil();
			}

			else 
			{
				temp = this.board[2 + nextJump][nextCol].getUtil();
			}

			if (temp > max) 
			{
				max = temp;
				this.board[r][c].setDir(nextJump);
			}
		}
		board[r][c].setUtil(REWARD + DISCOUNT_FACTOR*max);
	}

	/** Reset the Board of temp by copying elements from bd to temp
	 * @param bd the board elements to copy from
	 * @param temp the board in which the elements of bd is copied to
	 * @return a new temp board
	 */
	private static Node[][] resetBoard(Node[][] temp, Node[][] bd)
	{
		int row = bd.length;
		int col = bd[0].length;
		for (int i=0; i<row; i++)
		{
			for (int j=0; j<col; j++)
			{
				temp[i][j].setUtil(bd[i][j].getUtil());
				temp[i][j].setDir(bd[i][j].getDir());
			}
		}
		return temp;
	}

	/** Duplicate a Board
	 * @param bd the board that is to be duplicated.
	 * @return return a new board that is same as the board that is passed in. 
	 */
	private static Node[][] duplicate(Node[][] bd)
	{
		int row = bd.length;
		int col = bd[0].length;
		Node[][] temp = new Node[row][col];
		for (int i=0; i<row; i++) 
		{
			for (int j=0; j<col; j++) 
			{
				temp[i][j] = new Node(bd[i][j].getUtil(), bd[i][j].getDir());
			}
		}
		return temp;
	}

	/** Print Jump Path of Kangaroo
	 * Print the best path that maximize the kangaroo's utility of jumping from the startCell
	 * to the Food.
	 * @param startCell The starting cell of kangaroo.
	 * @param finalBoard The final board that contains the best policy to reach the food.
	 * @param prevJump the starting previous jump
	 */
	private void printPath(int startCell, int prevJump, Node[][] finalBoard)
	{
		int nextJump = finalBoard[prevJump][startCell].getDir();
		System.out.print("START: " + startCell);
		int nextCell;
		do 
		{
			nextCell = startCell + nextJump;
			if (nextCell < 0) 
			{
				nextCell = -nextCell - 1;
				nextJump = finalBoard[-nextJump+2][nextCell].getDir();
			}

			else if (nextCell >= this.numOfCells) 
			{
				nextCell = 2*this.numOfCells - nextCell - 1;
				nextJump = finalBoard[-nextJump+2][nextCell].getDir();
			}

			else if (nextCell == hole1 || nextCell == hole2)
			{
				System.out.print(" ==> " + nextCell);
				System.out.println(" :HOLE");
				return;
			}

			else 
			{
				nextJump = finalBoard[nextJump+2][nextCell].getDir();
			}
			System.out.print(" ==> " + nextCell);

			startCell = nextCell;
		} while (nextCell != food);
		System.out.println(" :FOOD");
	}

	static void print(String str, Node[][] bd)
	{
		int row = bd.length;
		int col = bd[0].length;
		int num = -2;
		System.out.println("========<" + str + ">========" );
		for (int i=0; i<row; i++) {
			System.out.print("prevJump=" + num++ + ": ");
			for (int j=0; j<col; j++) {
				System.out.format("%.2f, ", bd[i][j].getUtil());
			}
			System.out.println();
		}
		System.out.println("============================");
	}

	static void printDir(String str, Node[][] bd)
	{
		int row = bd.length;
		int col = bd[0].length;
		System.out.println("========<" + str + ">========" );
		int num = -2;
		for (int i=0; i<row; i++) {
			System.out.print("prevJump=" + num++ + ": ");
			for (int j=0; j<col; j++) {
				System.out.format("%2d, ", bd[i][j].getDir());
			}
			System.out.println();
		}
		System.out.println("============================");
	}

}
